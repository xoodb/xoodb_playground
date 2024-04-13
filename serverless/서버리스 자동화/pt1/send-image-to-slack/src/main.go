package main

import (
	"fmt"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/slack-go/slack"
)

const (
	AwsRegion = "ap-northeast-2"
	ChannelId = "C06H1UCHND8"
	PreURL    = "https://devops-slack-image-search.s3.ap-northeast-2.amazonaws.com"
)

var awsSession *session.Session

type Response events.APIGatewayProxyResponse
type Request events.APIGatewayProxyRequest

func getAwsSession() *session.Session {
	if awsSession == nil {
		awsSession = session.Must(session.NewSession(&aws.Config{Region: aws.String(AwsRegion)}))
	}
	return awsSession
}

func sendMessageToSlack(sess *session.Session, slackToken string, searchKeyword string) error {

	api := slack.New(slackToken)

	var msgBlocks []slack.Block
	titleObject := slack.NewTextBlockObject("plain_text", searchKeyword, true, false)
	imageBlock := slack.NewImageBlock(fmt.Sprintf("%s/%s.jpg", PreURL, searchKeyword), "", "", titleObject)
	msgBlocks = append(msgBlocks, imageBlock) // S3에서 이미지를 검색하는 로직 추가하기

	attachment := slack.Attachment{
		Color:  "default",
		Blocks: slack.Blocks{msgBlocks},
	}

	channelId, timestamp, slackErr := api.PostMessage(
		ChannelId,
		slack.MsgOptionText("", false),
		slack.MsgOptionAttachments(attachment),
		slack.MsgOptionAsUser(false),
	)

	if slackErr != nil {
		return slackErr
	}

	fmt.Printf("Message successfully sent to Channel %s at %s\n", channelId, timestamp)
	return nil
}

func parsingQuery(query string) string {
	items := strings.Split(query, "&")

	// create and fill the map
	key := make(map[string]string)
	for _, item := range items {
		x := strings.Split(item, "=")
		key[x[0]] = x[1]
	}
	return key["text"]
}

func Handler(request Request) (Response, error) {
	//parsing Body and extract searchKeyword
	searchKeyword := parsingQuery(request.Body)

	//get Aws Session
	sess := getAwsSession()

	//get SlackToken from parameter store
	slackToken := "xoxb-6592617444385-6579856795619-3KGHHXIySpUgBwNnwATNfcei" // AWS 에서 가져오는 로직으로 바꾸는걸 추천

	//send slack message
	err := sendMessageToSlack(sess, slackToken, searchKeyword)
	if err != nil {
		fmt.Println(err)
	}
	resp := Response{
		StatusCode:      200,
		IsBase64Encoded: false,
		Headers: map[string]string{
			"Content-Type": "application/json",
		},
	}

	return resp, nil
}

func main() {
	lambda.Start(Handler)
}

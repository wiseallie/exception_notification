require 'test_helper'
require 'slack-notifier'

class SlackNotifierTest < ActiveSupport::TestCase

  test "should send a slack notification if properly configured" do
    options = {
      webhook_url: "http://slack.webhook.url"
    }

    Slack::Notifier.any_instance.expects(:ping).with(fake_notification, {})

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)
    slack_notifier.call(fake_exception)
  end

  test "should send the notification to the specified channel" do
    options = {
      webhook_url: "http://slack.webhook.url",
      channel: "channel"
    }

    Slack::Notifier.any_instance.expects(:ping).with(fake_notification, {})

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)
    slack_notifier.call(fake_exception)

    assert_equal slack_notifier.notifier.channel, options[:channel]
  end

  test "should send the notification to the specified username" do
    options = {
      webhook_url: "http://slack.webhook.url",
      username: "username"
    }

    Slack::Notifier.any_instance.expects(:ping).with(fake_notification, {})

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)
    slack_notifier.call(fake_exception)

    assert_equal slack_notifier.notifier.username, options[:username]
  end

  test "should pass the additional parameters to Slack::Notifier.ping" do
    options = {
      webhook_url: "http://slack.webhook.url",
      username: "test",
      custom_hook: "hook",
      additional_parameters: {
        icon_url: "icon",
      }
    }

    Slack::Notifier.any_instance.expects(:ping).with(fake_notification, {icon_url: "icon"})

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)
    slack_notifier.call(fake_exception)
  end

  test "shouldn't send a slack notification if webhook url is missing" do
    options = {}

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)

    assert_nil slack_notifier.notifier
    assert_nil slack_notifier.call(fake_exception)
  end

  test "should pass along environment data" do
    exception = fake_exception
    exception.expects(:backtrace).times(3).returns(["foo line 1", "bar line 20"])
    exception.expects(:message).twice.returns('exception message')

    options = {
      webhook_url: "http://slack.webhook.url"
    }

    notification_options = {
      env: {
        'exception_notifier.exception_data' => {foo: 'bar', john: 'doe'}
      },
      data: {
        'user_id' => 5,
        'error_backtrace' => ["ignored backtrace"]
      }
    }

    expected_message =
      "#{fake_notification(exception)}\n" \
      "*Data:*\n"                         \
      "foo: bar, john: doe, user_id: 5\n" \
      "*Backtrace:*\n"                    \
      "foo line 1\n"                      \
      "bar line 20"

    Slack::Notifier.any_instance.expects(:ping).with(expected_message, {})
    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)
    slack_notifier.call(exception, notification_options)
  end

  private

  def fake_exception
    begin
      5/0
    rescue Exception => e
      e
    end
  end

  def fake_notification(exception=fake_exception)
    "An exception occurred: '#{exception.message}' on '#{exception.backtrace.first}'"
  end
end

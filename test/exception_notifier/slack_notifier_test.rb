require 'test_helper'
require 'slack-notifier'

class SlackNotifierTest < ActiveSupport::TestCase

  test "should send a slack notification if properly configured" do
    options = {
      token: "token",
      team:  "team"
    }

    Slack::Notifier.any_instance.expects(:ping).with(fake_notification, {})

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)
    slack_notifier.call(fake_exception)
  end

  test "should send a notification as the specified hook" do
    options = {
      token: "token",
      team:  "team",
      custom_hook: "custom"
    }

    Slack::Notifier.any_instance.expects(:ping).with(fake_notification, {})

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)
    slack_notifier.call(fake_exception)

    assert_equal slack_notifier.notifier.hook_name, "custom"
  end

  test "should send the notification to the specified channel" do
    options = {
      token: "token",
      team:  "team",
      channel: "channel"
    }

    Slack::Notifier.any_instance.expects(:ping).with(fake_notification, {})

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)
    slack_notifier.call(fake_exception)

    assert_equal slack_notifier.notifier.channel, options[:channel]
  end

  test "should send the notification to the specified username" do
    options = {
      token: "token",
      team:  "team",
      username: "username"
    }

    Slack::Notifier.any_instance.expects(:ping).with(fake_notification, {})

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)
    slack_notifier.call(fake_exception)

    assert_equal slack_notifier.notifier.username, options[:username]
  end

  test "should have the username 'ExceptionNotifierBot' when unspecified" do
    options = {
      token: "token",
      team:  "team",
    }

    Slack::Notifier.any_instance.expects(:ping).with(fake_notification, {})

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)
    slack_notifier.call(fake_exception)

    assert_equal slack_notifier.notifier.username, 'ExceptionNotifierBot'
  end

  test "should pass the additional parameters to Slack::Notifier.ping" do
    options = {
      token: "token",
      team:  "team",
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

  test "shouldn't send a slack notification if token is missing" do
    options = {
      team: "test"
    }

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)

    assert_nil slack_notifier.notifier
    assert_nil slack_notifier.call(fake_exception)
  end

  test "shouldn't send a slack notification if team is missing" do
    options = {
      token: "test"
    }

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)

    assert_nil slack_notifier.notifier
    assert_nil slack_notifier.call(fake_exception)
  end

  private

  def fake_exception
    begin
      5/0
    rescue Exception => e
      e
    end
  end

  def fake_notification
    "An exception occurred: '#{fake_exception.message}' on '#{fake_exception.backtrace.first}'"
  end
end

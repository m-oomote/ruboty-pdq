require "ruboty/pdq/helpers/brain"
require "ruboty/pdq/helpers/smartdb"
require "ruboty/pdq/helpers/slack"
require "ruboty/pdq/helpers/util"
require "ruboty/pdq/actions/list"
require "ruboty/pdq/actions/help"
require "ruboty/pdq/actions/count"

module Ruboty
  module Handlers
    class Pdq < Base
      $stdout.sync = true
      on /pdq help/, name: 'help', description: 'show help'
      on /pdq count *(?<cmd>ise|sdb|all)*\z/, name: 'count', description: 'show the count of the question'
      on /pdq list *(?<period>\d+)*\z/, name: 'list', description: 'show the question list'

      def list(message)
        Ruboty::Pdq::Actions::List.new(message).call
      end

      def help(message)
        Ruboty::Pdq::Actions::Help.new(message).call
      end

      def count(message)
        Ruboty::Pdq::Actions::Count.new(message).call
      end

    end
  end
end

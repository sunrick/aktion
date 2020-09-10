module Aktion
  module Hooks
    def before(klass)
      @before_actions << klass
    end

    def before_actions
      @before_actions ||= []
    end

    def after(klass)
      @after_actiosn << klass
    end

    def after_actions
      @after_actions ||= []
    end

    def inherited(subclass)
      subclass.inherit_before_actions(before_actions)
      subclass.inherit_after_actions(after_actions)
    end

    def inherit_before_actions(child_before_actions)
      before_actions.concat(child_before_actions)
    end

    def inherit_after_actions(child_after_actions)
      after_actions.concat(child_after_actions)
    end
  end
end

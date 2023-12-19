module Helpers
  module Js
    def click_outside
      find('body').click
    end

    def open_choicesjs_dropdown(from, &)
      find('label', text: from, exact_text: true).click
      return unless block_given?

      within(find('label', text: from, exact_text: true).ancestor('.simple_form__label_wrapper').sibling('.choices'),
             &)
    end

    def choicesjs_select_option_css
      '.choices__item--selectable'
    end

    def expect_option_to_be_presented(option, from:)
      open_choicesjs_dropdown(from) do
        expect(page).to have_css(choicesjs_select_option_css, text: option)
      end
    end

    def choicesjs_select(option, from:, single: true)
      open_choicesjs_dropdown(from) do
        Array(option).each do |opt|
          find(choicesjs_select_option_css, text: opt).click
        end
      end
    end
  end
end

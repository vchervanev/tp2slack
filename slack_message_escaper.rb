module SlackMessageEscaper

  TEMPLATES = {
      '&' => '&amp;',
      '<' => '&lt;',
      '>' => '&gt;',
  }

  def escape(message)
    TEMPLATES.each do |sym, text|
      message = message.gsub(sym, text)
    end

    message
  end
  module_function :escape
end
# frozen_string_literal: true

require "digest"

module MyRubyCodingAgents
  # Marks rendered agent files with a hash of their content, so a later
  # install can tell an untouched generated file from one a person edited.
  module Generated
    NAME = "my-ruby-coding-agents"
    MARKER = /^(?:# #{NAME}: (?<hash>[0-9a-f]{16})|<!-- #{NAME}: (?<hash>[0-9a-f]{16}) -->)\r?\n/
    FRONTMATTER = /\A---\r?\n.*?\r?\n---\r?\n/m

    module_function

    # Adds the marker line. style is :toml (first line) or :markdown
    # (right after the frontmatter). The hash covers the content without
    # the marker line.
    def stamp(content, style:)
      hash = digest(content)
      case style
      when :toml then "# #{NAME}: #{hash}\n#{content}"
      when :markdown then stamp_markdown(content, hash)
      else raise ArgumentError, "unknown marker style: #{style.inspect}"
      end
    end

    # :unmodified when the marker hash matches the rest of the file,
    # :modified when it does not, :foreign when there is no marker.
    def status(existing_content)
      match = existing_content.match(MARKER)
      return :foreign unless match

      rest = match.pre_match + match.post_match
      match[:hash] == digest(rest) ? :unmodified : :modified
    end

    def digest(content)
      Digest::SHA256.hexdigest(content)[0, 16]
    end

    def stamp_markdown(content, hash)
      match = content.match(FRONTMATTER)
      raise ArgumentError, "Markdown content must begin with frontmatter" unless match

      "#{match[0]}<!-- #{NAME}: #{hash} -->\n#{match.post_match}"
    end
    private_class_method :stamp_markdown
  end
end

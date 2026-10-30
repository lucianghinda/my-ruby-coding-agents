# frozen_string_literal: true

require "test_helper"
require "my_ruby_coding_agents/generated"

class TestGenerated < Minitest::Test
  MARKDOWN = "---\nname: x\n---\n\nBody\n"

  def stamp(content, style)
    MyRubyCodingAgents::Generated.stamp(content, style:)
  end

  def status(content)
    MyRubyCodingAgents::Generated.status(content)
  end

  def test_stamps_toml_on_first_line
    assert_equal "# my-ruby-coding-agents: cb78bd8a17f7b751\na = 1\n", stamp("a = 1\n", :toml)
  end

  def test_stamps_markdown_after_frontmatter
    assert_equal "---\nname: x\n---\n<!-- my-ruby-coding-agents: bf4dd6260834697d -->\n\nBody\n",
                 stamp(MARKDOWN, :markdown)
  end

  def test_hash_is_sha256_prefix_of_content_without_marker
    assert_equal Digest::SHA256.hexdigest(MARKDOWN)[0, 16], stamp(MARKDOWN, :markdown)[/: (\h{16}) -->/, 1]
  end

  def test_status_unmodified_when_hash_matches
    assert_equal :unmodified, status(stamp("a = 1\n", :toml))
    assert_equal :unmodified, status(stamp(MARKDOWN, :markdown))
  end

  def test_status_modified_when_content_changes
    assert_equal :modified, status(stamp("a = 1\n", :toml).sub("1", "2"))
    assert_equal :modified, status(stamp(MARKDOWN, :markdown).sub("Body", "Edited body"))
  end

  def test_status_foreign_without_marker
    assert_equal :foreign, status(MARKDOWN)
    assert_equal :foreign, status("<!-- my-ruby-coding-agents:start -->\nx\n")
  end

  def test_rejects_markdown_without_frontmatter
    error = assert_raises(ArgumentError) { stamp("Body\n", :markdown) }
    assert_equal "Markdown content must begin with frontmatter", error.message
  end

  def test_rejects_unknown_style
    assert_raises(ArgumentError) { stamp("x", :yaml) }
  end
end

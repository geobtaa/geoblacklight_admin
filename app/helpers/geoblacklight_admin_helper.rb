# frozen_string_literal: true

# GeoblacklightAdminHelper
module GeoblacklightAdminHelper
  # @TODO:
  # Cannot generate app if uncommented...
  # Uncomment after app is generated to fix view errors
  include ::Pagy::Frontend if defined?(Pagy)

  # jbuilder helper
  def no_json_blanks(value)
    case value
    when String
      value.presence
    when Array
      value.join.blank? ? nil : value
    end
  end

  # qa (questioning_authoriry) gem oddly gives us no route helpers, so
  # let's make one ourselves, for it's current mount point, we can change
  # it if needed but at least it's DRY.
  def qa_search_vocab_path(vocab, subauthority = nil)
    path = "/authorities/search/#{CGI.escape vocab}"

    path += "/#{CGI.escape subauthority}" if subauthority

    path
  end

  def flash_class(level)
    alerts = {
      "notice" => "alert alert-info",
      "success" => "alert alert-success",
      "error" => "alert alert-error",
      "alert" => "alert alert-error"
    }
    alerts[level]
  end

  def b1g_institution_codes
    {
      "01" => "Indiana University",
      "02" => "University of Illinois Urbana-Champaign",
      "03" => "University of Iowa",
      "04" => "University of Maryland",
      "05" => "University of Minnesota",
      "06" => "Michigan State University",
      "07" => "University of Michigan",
      "08" => "Purdue University",
      "09" => "Pennsylvania State University",
      "10" => "University of Wisconsin-Madison",
      "11" => "The Ohio State University",
      "12" => "University of Chicago",
      "13" => "University of Nebraska-Lincoln",
      "14" => "Rutgers University-New Brunswick",
      "15" => "Northwestern University"
    }
  end

  def bookmarks_badge
    bookmarks_classes = ["badge", "badge-dark"]
    "<span class='#{bookmarks_classes.join(" ")}' id='bookmarks-count'>#{current_user.bookmarks.size}</span>"
  end

  def notifications_badge
    notifications_classes = ["badge"]
    notifications_classes << "badge-dark" if current_user.notifications.unread.empty?
    notifications_classes << "badge-danger" if current_user.notifications.unread.size.positive?
    "<span class='#{notifications_classes.join(" ")}' id='notification-count'>#{current_user.notifications.unread.size}</span>"
  end

  # From Blacklight::HiddenSearchStateComponent
  def params_as_hidden_fields(params)
    hidden_fields = []
    flatten_hash(params).each do |name, value|
      value = Array.wrap(value)
      value.each do |v|
        hidden_fields << hidden_field_tag(name, v.to_s, id: nil)
      end
    end

    safe_join(hidden_fields, "\n")
  end

  def flatten_hash(hash, ancestor_names = [])
    flat_hash = {}
    hash.each do |k, v|
      names = Array.new(ancestor_names)
      names << k
      if v.is_a?(Hash)
        flat_hash.merge!(flatten_hash(v, names))
      else
        key = flat_hash_key(names)
        key += "[]" if v.is_a?(Array)
        flat_hash[key] = v
      end
    end

    flat_hash
  end

  def flat_hash_key(names)
    names = Array.new(names)
    name = names.shift.to_s.dup
    names.each do |n|
      name << "[#{n}]"
    end
    name
  end

  def diff_class(char)
    case char
    when "~"
      "table-warning"
    when "-"
      "table-danger"
    when "+"
      "table-success"
    else
      ""
    end
  end

  def link_to_admin_import(import)
    path = admin_documents_path(
      {
        f: {b1g_geom_import_id_ssi: [import]}
      }
    )

    link_to import.name, path
  end

  def link_to_gbl_import(label, import, state = false)
    path = if state
      blacklight_path(
        {
          f: {b1g_geom_import_id_ssi: [import]},
          publication_state: state
        }
      )
    else
      blacklight_path(
        {
          f: {b1g_geom_import_id_ssi: [import]},
          publication_state: "*"
        }
      )
    end

    link_to(label, path)
  end

  def assets_dct_references_options
    escape_javascript(options_for_select(I18n.t("activemodel.enum_values.document/reference.category").invert.sort.insert(0, ["Choose Reference Type", nil]))).to_s
  end
end

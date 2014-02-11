(($, Backbone) ->
    AjaxSettingsModel = Backbone.Model.extend
        url: ajaxurl + "?action=ajax_settings_save"
        parse: (data, options)->
            # initialize
            if options.form
                @optionsName = options.name
                @url = ajaxurl + "?action=ajax_settings_save_#{@optionsName}"
                @$form = options.form
                _.extend data, @$form.serializeObject()
        isNew: () -> false
        update: (el) ->
            $el = $(el)
            if $el.is(':checkbox')
                el.value = if $el.is(':checked') then 1 else 0

            @saving = true
            @save el.name, el.value,
                success: @saveSuccess.bind(this)
                error: @saveError.bind(this)

        saveSuccess: (obj, data) ->
            @saving = false
        saveError: (obj, data) ->
            @saving = false
            console.log obj, data

        findInput: (name, opts={}) ->
            if !@_is
                @_is = {}

            if !@_is[name]
                @_is[name] = @$form
                    .find('input, select')
                    .filter("[name='#{name}']")

            @_is[name]

    $.fn.serializeObject = (form) ->
        serialized = {}
        for obj in $(this).serializeArray()
            serialized[obj.name] = obj.value
        serialized

    AjaxSettingsModel.extend = Backbone.Model.extend
    this.AjaxSettingsModel = AjaxSettingsModel

).call(this, jQuery, Backbone)
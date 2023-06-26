class EventPresenter < StageablePresenter
  def filter_link
    if object.rerun_event?
      object.original_event.filter_link
    else
      super
    end
  end

  def type_color
    'badge-warning'
  end
end

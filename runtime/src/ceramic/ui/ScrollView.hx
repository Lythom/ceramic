package ceramic.ui;

import ceramic.Scroller;
import ceramic.ScrollDirection;

class ScrollView extends View {

/// Properties

    public var scroller:Scroller;

    public var contentView:View;

    public var contentSize(default,set):Float = -1;
    inline function set_contentSize(contentSize:Float):Float {
        if (this.contentSize == contentSize) return contentSize;
        contentSize = Math.max(0, contentSize);
        this.contentSize = contentSize;
        layoutDirty = true;
        return contentSize;
    }

    public var direction(get,set):ScrollDirection;
    inline function get_direction():ScrollDirection {
        return scroller.direction;
    }
    inline function set_direction(direction:ScrollDirection):ScrollDirection {
        return scroller.direction = direction;
    }

/// Lifecycle

    public function new(#if ceramic_debug_entity_allocs ?pos:haxe.PosInfos #end) {

        super(#if ceramic_debug_entity_allocs pos #end);

        initContentView();
        initScroller();

    } //new

    function initContentView() {

        contentView = new View();

    } //initContentView

    function initScroller() {

        scroller = new Scroller(contentView);
        add(scroller);

    } //initScroller

    override function layout() {

        scroller.pos(0, 0);
        scroller.size(width, height);

        if (direction == VERTICAL) {
            contentView.height = Math.max(height, contentSize);
        } else {
            contentView.width = Math.max(width, contentSize);
        }

    } //layout

} //ScrollView

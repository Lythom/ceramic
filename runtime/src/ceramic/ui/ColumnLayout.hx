package ceramic.ui;

/** A layout that arranges its children vertically in a single row.
    This class is a `LinearLayout` subclass, restricted to its vertical direction. */
class ColumnLayout extends LinearLayout {

    public function new() {

        super();
        direction = VERTICAL;

    } //new

    override function set_direction(direction:LayoutDirection):LayoutDirection {

        if (direction != VERTICAL) throw('Changing direction of a ColumnLayout is not allowed. Use a LinearLayout if you want to change direction at runtime.');
        return this.direction = VERTICAL;

    } //set_direction

} //ColumnLayout

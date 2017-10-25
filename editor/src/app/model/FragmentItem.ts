import { serialize, observe, compute, serializeModel, Model } from 'utils';
import { project } from 'app/model';

class FragmentItem extends Model {

/// Sort

    /** Item sort index */
    @observe @serialize sortIndex:number = 0;

/// Lock

    /** Item locked state */
    @observe @serialize locked:boolean = false;

/// Properties

    /** Item entity class */
    @observe @serialize entity:string;

    /** Item name */
    @observe @serialize name:string = '';

    /** Props */
    @observe @serialize props:Map<string,any> = new Map();

/// Helpers

    serializeForCeramic() {

        let serialized = serializeModel(this, { exclude: ['_model'] });
        let data:any = { props: {}, data: {} };

        let skipSize = false;

        for (let key in serialized) {
            if (serialized.hasOwnProperty(key)) {
                if (key === 'locked' || key === 'name') {
                    data.data[key] = serialized[key];
                }/* else if (key === 'id' || key === 'entity' || key === 'sortIndex') {
                    data[key] = serialized[key];
                } else if (key === 'explicitWidth') {
                    if (serialized[key] != null) {
                        data.props.width = serialized[key];
                    }
                } else if (key === 'explicitHeight') {
                    if (serialized[key] != null) {
                        data.props.height = serialized[key];
                    }
                }*/
                else if (key === 'props') {
                    for (let k in serialized[key]) {
                        if (serialized[key].hasOwnProperty(k)) {
                            if ((k === 'width' || k === 'height') && this.implicitSize) {
                                // Skip field
                            }
                            else {
                                data.props[k] = serialized[key][k];
                            }
                        }
                    }
                }
                else {
                    data[key] = serialized[key];
                }
            }
        }

        return data;

    } //serializeForCeramic

    @compute get implicitSize():boolean {
        
        let info = project.editableTypesByKey.get(this.entity);
        if (info != null && info.meta != null && info.meta.editable != null) {
            let opts = info.meta.editable[0];
            if (opts.implicitSize) {
                return true;
            }
            else if (opts.implicitSizeUnlessNull != null) {
                return this.props.get(opts.implicitSizeUnlessNull) != null;
            }
        }

        return false;

    } //implicitSize

} //FragmentItem

export default FragmentItem;
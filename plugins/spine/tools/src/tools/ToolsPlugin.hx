package tools;

import tools.Context;
import tools.Helpers;
import tools.Helpers.*;
import haxe.io.Path;

@:keep
class ToolsPlugin {

    static function main():Void {
        
        var module:Dynamic = js.Node.module;
        module.exports = new ToolsPlugin();

    } //main

/// Tools

    public function new() {}

    public function init(context:Context):Void {

        // Use same context as parent
        Helpers.context = context;

        // Add tasks
        var tasks = context.tasks;
        tasks.set('spine export', new tools.tasks.spine.ExportSpine());
        tasks.set('spine run', new tools.tasks.spine.RunSpine());

    } //init

    public function extendProject(project:Project):Void {

        var app = project.app;
        
        if (app.spine) {
            app.paths.push(Path.join([context.plugins.get('Spine').path, 'runtime/src']));
            app.editable.push('ceramic.Spine');
        }

    } //extendProject

} //ToolsPlugin

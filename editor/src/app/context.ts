import { observe, ceramic, serialize } from 'utils';
import * as electron from 'electron';
import shortcuts from './shortcuts';
const electronApp = electron.remote.require('./app.js');

/** Track app info such as fullscreen, width, height, project path.. */
export class Context {

/// Properties

    @observe fullscreen:boolean = false;

    @observe width:number = 0;

    @observe height:number = 0;

    @observe serverPort:number = null;

    @observe ceramicReady:boolean = false;

    @observe draggingOver:boolean = false;

/// Constructor

    constructor() {

        // Get electron window
        let appWindow = electron.remote.getCurrentWindow();

        // Get current state
        this.fullscreen = appWindow.isFullScreen();
        this.width = window.innerWidth;
        this.height = window.innerHeight;

        // Listen state changes
        const handleFullScreen = () => {
            this.fullscreen = appWindow.isFullScreen();
        };
        appWindow.addListener('enter-full-screen', handleFullScreen);
        appWindow.addListener('leave-full-screen', handleFullScreen);
        const handleClose = () => {
            appWindow.removeListener('enter-full-screen', handleClose);
            appWindow.removeListener('leave-full-screen', handleClose);
            appWindow.removeListener('close', handleClose);
        };
        appWindow.addListener('close', handleClose);
        let sizeTimeout:any = null;
        const handleResize = () => {
            if (sizeTimeout != null) clearTimeout(sizeTimeout);
            sizeTimeout = setTimeout(() => {
                sizeTimeout = null;
                this.width = window.innerWidth;
                this.height = window.innerHeight;
            }, 100);
        };
        window.addEventListener('resize', handleResize);
        window.addEventListener('orientationchange', handleResize);

        // Get server port
        const checkServerPort = () => {
            this.serverPort = electronApp.serverPort;
            if (this.serverPort == null) {
                setTimeout(checkServerPort, 100);
            }
        };
        checkServerPort();
        
        // Default ceramic state is false
        this.ceramicReady = false;

        // Create menu/shortcuts
        shortcuts.initialize();

    } //constructor

} //Context

export const context = new Context();
package {
    import flash.display.Sprite;
    import flash.events.*;
    import flash.net.FileFilter;
    import flash.net.FileReference;
    import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import org.flixel.*;

	//This code seems to be designed to send a file to a specified page online. Could be modified not only to open saved
	// games, but also to pass data to a php server to maybe run multi-player content.
	
    public class LoadGame extends FlxGroup {
		
		/* ####################### File-related variables ############################## */
        private var uploadURL:URLRequest;
        private var file:FileReference;
		
		/**
		 * The data loaded from the save file.
		 */
		public var data:ByteArray;
		
		/**
		 * Whether loading has started.
		 */
		public var startedLoading:Boolean;
		
		/**
		 * Whether loading has finished.
		 */
		public var doneLoading:Boolean;
		
		/**
		 * Whether loading was cancelled. The MainMenuState deletes the active LoadGame object if it has cancelled = true;
		 */
		public var cancelled:Boolean;
		
		/* ######################## Display-related variables ################################ */
		
		/**
		 * Background image used for the loading window.
		 */
		public var background:FlxSprite;
		
		/**
		 * Loading bar used to display the file's loading progress.
		 */
		public var loadBar:DispBar;
		
		/**
		 * What to call when the load attempt is successful.
		 */
		public var callback:Function;
		
		/**
		 * Constructor for the LoadGame object.
		 * @param	_callback What function to call when loading of the save file is complete (and successful).
		 */
        public function LoadGame(_callback:Function = null) {
			callback = _callback;
			
			background = new FlxSprite(FlxG.width / 2 - 100, FlxG.height / 2 - 100);
			background.makeGraphic(200, 200, 0xffcccccc);
			background.scrollFactor.x = background.scrollFactor.y = 0;
			add(background);
			
			loadBar = new DispBar(background.x + 75, background.y + 25);
			loadBar.changeColors(0xff6666ff, 0xff111133);
			loadBar.scrollFactor.x = loadBar.scrollFactor.y = 0;
			loadBar.value = 0;
			loadBar.update();
			add(loadBar);
			
			startedLoading = false;
			doneLoading = false;
			cancelled = false;
            //uploadURL = new URLRequest();
            //uploadURL.url = "http://www.artofmartincarney.com/index.php";
            file = new FileReference();
            configureListeners(file);
        }
		
		/**
		 * Standard update cycle for the displayed portions of the LoadGame object.
		 */
		override public function update():void {
			super.update();
			if (!startedLoading) {
				browse();
				startedLoading = true;
			}
		}
		
		/**
		 * Opens the browse window to let the user find a save game file on their computer.
		 */
		public function browse():void {
            file.browse(getTypes());
		}

        private function configureListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.CANCEL, cancelHandler);
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            dispatcher.addEventListener(Event.OPEN, openHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(Event.SELECT, selectHandler);
            dispatcher.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,uploadCompleteDataHandler);
        }
		
		/**
		 * Sets what file types the browse dialog will accept.
		 * @return An array of FileFilters to limit what file types to allow.
		 */
        private function getTypes():Array {
            var allTypes:Array = new Array(getTextTypeFilter(), getImageTypeFilter());
            return allTypes;
        }

        private function getImageTypeFilter():FileFilter {
            return new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png");
        }

        private function getTextTypeFilter():FileFilter {
            return new FileFilter("Text Files (*.txt, *.rtf)", "*.txt;*.rtf");
        }
		
		/**
		 * How to handle a cancelled attempt to load.
		 * @param	event
		 */
        private function cancelHandler(event:Event):void {
			cancelled = true;
            trace("cancelHandler: " + event);
        }
		
		/**
		 * This is where you tell the program what to do when the file is done.
		 * @param	event
		 */
        private function completeHandler(event:Event):void {
			doneLoading = true;
			data = file.data;
            trace("completeHandler: " + event);
			if (callback != null) {
				callback();
			}
        }

        private function uploadCompleteDataHandler(event:DataEvent):void {
            trace("uploadCompleteData: " + event);
        }

        private function httpStatusHandler(event:HTTPStatusEvent):void {
            trace("httpStatusHandler: " + event);
        }
        
        private function ioErrorHandler(event:IOErrorEvent):void {
            trace("ioErrorHandler: " + event);
        }
		
		/**
		 * What to do when a file is first opened. (Why does this happen twice...?);
		 * @param	event
		 */
        private function openHandler(event:Event):void {
            trace("openHandler: " + event);
        }
		
		/**
		 * How to handle the progress of the loading file (useful for updating a loading bar).
		 * @param event
		 */
        private function progressHandler(event:ProgressEvent):void {
            var file:FileReference = FileReference(event.target);
            trace("progressHandler: name=" + file.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
			loadBar.changeParent(event, "bytesLoaded", event.bytesTotal);
			loadBar.value = event.bytesLoaded;
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void {
            trace("securityErrorHandler: " + event);
        }
		
		/**
		 * This is where you tell the program what to do with the file you've just selected.
		 * @param	event
		 */
        private function selectHandler(event:Event):void {
			data = null;
            var file:FileReference = FileReference(event.target);
            trace("selectHandler: name=" + file.name);
            file.load();
        }
		
		/**
		 * Destroys and null-references all the objects in this object for garbage collection.
		 */
		override public function destroy():void {
			//background.destroy();
			//background = null;
			//loadBar.destroy();
			//loadBar = null;
			super.destroy();
		}
    }
}
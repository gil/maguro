/*
   Copyright (c) 2009 Maguro Contributors.
   See: http://github.com/gil/maguro/

   Permission is hereby granted, free of charge, to any person obtaining a copy of
   this software and associated documentation files (the "Software"), to deal in
   the Software without restriction, including without limitation the rights to
   use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
   of the Software, and to permit persons to whom the Software is furnished to do
   so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.
 */
package maguro.controls
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import maguro.crypto.MD5;

	import mx.collections.ArrayCollection;
	import mx.controls.TextInput;
	import mx.effects.AnimateProperty;
	import mx.events.EffectEvent;

	/**
	 * Password field that shows color bars to help checking if the typed password is correct.
	 *
	 * Idea from the jQuery plugin Chroma-Hash (http://github.com/mattt/Chroma-Hash/), by Mattt Thompson.
	 * See http://mattt.me/2009/07/chroma-hash-a-belated-introduction/ for more info.
	 */
	public class ColorPasswordField extends TextInput
	{

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 *  Constructor.
		 */
		public function ColorPasswordField()
		{
			super();

			// Force to display as password
			super.displayAsPassword = true;

			// Add a listner to change the color bars
			this.addEventListener(Event.CHANGE, textChanged);
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _textChanged:Boolean = false;

		/**
		 * @private
		 */
		private var _drawTimer:Timer;

		/**
		 * @private
		 * Reference to the color bars.
		 */
		private var _bars:ArrayCollection = new ArrayCollection();

		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------

		/**
		 * Force this field to display always as a password.
		 */
		override public function set displayAsPassword(value:Boolean):void
		{
			super.displayAsPassword = true;
		}

		/**
		 * If somebody set the text property directly, mark as changed too.
		 */
		override public function set text(value:String):void
		{
			super.text = value;

			textChanged();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * The total width to draw all the color bars.
		 *
		 * @default 27
		 */
		public var barsSpaceSize:int = 27;

		/**
		 * The color bar count.
		 *
		 * @default 3
		 */
		public var barCount:int = 3;

		/**
		 * The security delay to show the color bars.
		 *
		 * @default 300
		 */
		public var securityDelay:int = 300;

		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------

		/**
		 *  @private
		 *  If necessary, remove the color bars and draw the new ones.
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			// When the user changed the password 
			if (_textChanged)
			{
				_textChanged = false;

				textField.width = this.width - barsSpaceSize - 4;

				if (this.text != null)
				{
					removeColorBars()

					if (this.text != "")
					{
						drawColorBarsWithDelay(securityDelay);
					}
				}
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Set the flag to draw the color bars again and invalidate the display list.
		 */
		private function textChanged(event:Event = null):void
		{
			_textChanged = true;
			invalidateDisplayList();
		}

		/**
		 * @private
		 * Get the MD5 hash from the text property.
		 */
		private function getTextMD5():String
		{
			return MD5.hash(this.text);
		}

		/**
		 * @private
		 * Apply a fade effect on the sprite.
		 *
		 * @param sprite The sprite.
		 */
		private function fadeSprite(sprite:Sprite, fromValue:int, toValue:int, effectEndHandler:Function = null):void
		{
			var effect:AnimateProperty = new AnimateProperty(sprite);

			if (effectEndHandler != null)
			{
				effect.addEventListener(EffectEvent.EFFECT_END, effectEndHandler);
			}

			effect.duration = 300;
			effect.property = "alpha";
			effect.fromValue = fromValue;
			effect.toValue = toValue;

			effect.play();
		}

		/**
		 * @private
		 * Fade and then remove old color bars.
		 */
		private function removeColorBars():void
		{
			for each (var bar:Sprite in _bars)
			{
				// Fade to hide and remove bars on effect end
				fadeSprite(bar, 1, 0, removeSprite);
			}

			_bars.removeAll();
		}

		/**
		 * @private
		 * Remove the color bar sprite when the fade effect ends.
		 *
		 * @param event The effect end event.
		 */
		private function removeSprite(event:EffectEvent):void
		{
			var sprite:Sprite = (event.target as AnimateProperty).target as Sprite;

			if (sprite != null)
			{
				this.removeChildAt(this.getChildIndex(sprite));
			}
		}

		/**
		 * @private
		 * Wait some time to draw the color bars, so nobody can
		 * capture every color change to deduce the password.
		 *
		 * @param delay The delay to draw the color bars.
		 */
		private function drawColorBarsWithDelay(delay:int):void
		{
			if (_drawTimer != null && _drawTimer.running)
			{
				_drawTimer.stop();
			}

			_drawTimer = new Timer(delay, 1);
			_drawTimer.addEventListener(TimerEvent.TIMER, onDrawTimer);
			_drawTimer.start();
		}

		/**
		 * @private
		 * After the delay, draw the color bars
		 */
		private function onDrawTimer(event:TimerEvent):void
		{
			drawColorBars(getTextMD5());
		}

		/**
		 * @private
		 * Draw the color bars using the MD5 hash.
		 *
		 * @param md5 MD5 hash to draw the color bars.
		 */
		private function drawColorBars(md5:String):void
		{
			var barSize:int = barsSpaceSize / barCount;
			var md5Position:int = 0;

			for (var i:int = barSize; i <= barsSpaceSize; i += barSize)
			{
				// Get the color from the MD5 hash
				var color:uint = uint("0x" + md5.substr(md5Position++, 6));

				// Create the sprite
				var sprite:Sprite = new Sprite();
				sprite.graphics.beginFill(color);
				sprite.graphics.drawRect(this.width - i, 2, barSize - 2, this.height - 4);
				sprite.alpha = 0;

				// You can't get more than 26 good colors using a MD5 hash
				if (md5Position > 26)
				{
					md5Position = 0;
				}

				// Add the sprite to the component and the bars list
				this.addChild(sprite);
				_bars.addItem(sprite);

				// Effect to fade the bars
				fadeSprite(sprite, 0, 1);
			}
		}

	}
}
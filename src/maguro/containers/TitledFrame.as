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
package maguro.containers
{
	import mx.controls.Label;
	import mx.core.Container;
	import mx.events.FlexEvent;
	import mx.utils.StringUtil;

	[DefaultProperty("contentContainer")]

	/**
	 * Draw a border around the container and a title label.
	 */
	public class TitledFrame extends Container
	{

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 *  Constructor.
		 */
		public function TitledFrame()
		{
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const TITLE_LABEL_PADDING:int = 5;

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _titleChanged:Boolean = false;

		/**
		 * @private
		 */
		private var _showTitleLabel:Boolean = false;

		/**
		 * @private
		 */
		private var _contentContainerChanged:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _title:String;

		[Bindable]
		/**
		 * The frame title.
		 */
		public function get title():String
		{
			return _title;
		}

		/**
		 * @private
		 */
		public function set title(value:String):void
		{
			_title = value;
			_titleChanged = true;
			invalidateProperties();
		}

		/**
		 * @private
		 */
		private var _titleLabel:Label;

		/**
		 * Reference to the frame title label.
		 */
		public function get titleLabel():Label
		{
			return _titleLabel;
		}

		/**
		 * @private
		 */
		private var _oldContentContainer:Container;

		/**
		 * @private
		 */
		private var _contentContainer:Container;

		/**
		 * The frame content container.
		 */
		public function get contentContainer():Container
		{
			return _contentContainer;
		}

		/**
		 * @private
		 */
		public function set contentContainer(value:Container):void
		{
			_oldContentContainer = _contentContainer;
			_contentContainer = value;
			_contentContainerChanged = true;
			invalidateProperties();
		}

		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Create the frame title label.
		 */
		override protected function createChildren():void
		{
			super.createChildren();

			if (_titleLabel == null)
			{
				_titleLabel = new Label();
				_titleLabel.addEventListener(FlexEvent.UPDATE_COMPLETE, titleLabelUpdated);
				this.addChild(_titleLabel);
			}
		}

		/**
		 * @private
		 * Draw the frame title label and correctly align the border and the content container.
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			var _textHeight:int = 0;
			var _midTextHeight:int = 0;

			// Configure the label
			if (_titleLabel != null)
			{
				var _maxWidth:int = this.width - (TITLE_LABEL_PADDING * 2);

				_textHeight = _titleLabel.textHeight;
				_midTextHeight = _textHeight / 2;

				with (_titleLabel)
				{
					x = TITLE_LABEL_PADDING;
					y = 0;

					width = Math.min(_titleLabel.textWidth + TITLE_LABEL_PADDING, _maxWidth);
					height = _textHeight + 2;

					truncateToFit = true;
					visible = _showTitleLabel;
				}
			}

			// Draw the border
			with (this.graphics)
			{
				clear();
				beginFill(0x000000);

				// First border
				drawRect(0, _midTextHeight, this.width, this.height - _midTextHeight);

				// Remove the diference
				drawRect(1, _midTextHeight + 1, this.width - 2, this.height - _midTextHeight - 2);

				if (_titleLabel != null && _showTitleLabel)
				{
					// Remove the text space from border
					drawRect(TITLE_LABEL_PADDING - 1, _midTextHeight, _titleLabel.width, 1);
				}
			}

			// Set the content container position and size
			if (_contentContainer != null)
			{
				with (_contentContainer)
				{
					x = TITLE_LABEL_PADDING;
					y = _textHeight + TITLE_LABEL_PADDING;
					width = this.width - (TITLE_LABEL_PADDING * 2);
					height = this.height - _textHeight - (TITLE_LABEL_PADDING * 2);
				}
			}

		}

		/**
		 * @private
		 * Update the frame title and add the new content container.
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();

			if (_titleChanged)
			{
				_titleChanged = false;
				_titleLabel.text = _title;

				if (_title != null && StringUtil.trim(_title) != "")
				{
					_showTitleLabel = true;
				}
				else
				{
					_showTitleLabel = false;
				}

				invalidateDisplayList();
			}

			if (_contentContainerChanged)
			{
				_contentContainerChanged = false;

				// Remove the old content container, if necessary
				if (_oldContentContainer != null)
				{
					this.removeChild(_oldContentContainer);
				}

				// Add new the content container
				this.addChild(_contentContainer);

				invalidateDisplayList();
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * When the title label is updated, align everything again.
		 */
		private function titleLabelUpdated(event:FlexEvent):void
		{
			invalidateDisplayList();
		}

	}
}
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
	import mx.core.ContainerLayout;
	import mx.core.LayoutContainer;
	import mx.events.FlexEvent;
	import mx.skins.halo.HaloBorder;
	import mx.utils.StringUtil;

	[DefaultProperty("contentContainer")]

	[Exclude(name="borderStyle",kind="style")]
	[Exclude(name="borderSides",kind="style")]
	[Exclude(name="borderSkin",kind="style")]

	/**
	 * Draw a border around the container and a title label.
	 */
	public class TitledFrame extends LayoutContainer
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

			super.layout = ContainerLayout.ABSOLUTE;

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
			if (_contentContainer != null)
			{
				// Remove old content container
				this.removeChild(_contentContainer);
			}

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

			var textHeight:int = _titleLabel.height / 2;
			var bakckgroundColor:uint = this.getStyle("backgroundColor") == null ? 0xFFFFFF : this.getStyle("backgroundColor");

			with (_titleLabel)
			{
				// Set the title label properties
				x = TITLE_LABEL_PADDING;
				y = 0;
				maxWidth = this.width - (TITLE_LABEL_PADDING * 2);
				truncateToFit = true;
				visible = _showTitleLabel;

				// Draw a rect to make the label not transparent
				graphics.clear();
				graphics.beginFill(bakckgroundColor);
				graphics.drawRect(-1, 0, _titleLabel.width, _titleLabel.height);
			}

			if (_contentContainer != null)
			{
				with (_contentContainer)
				{
					// Set the content container position
					setStyle("top", 0);
					setStyle("left", 0);
					setStyle("right", 0);
					setStyle("bottom", 0);

					move(0, _titleLabel.height);
					height -= _titleLabel.height;
				}
			}

			// Force the component border
			this.setStyle("borderStyle", "solid");

			// Move the border correctly
			var _border:HaloBorder = (rawChildren.getChildByName("border") as HaloBorder);
			if (_border != null)
			{
				_border.move(0, textHeight);
				_border.height = this.height - textHeight;
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
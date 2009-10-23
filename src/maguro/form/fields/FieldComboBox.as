package maguro.form.fields
{
	import maguro.form.interfaces.IFormField;
	import mx.controls.ComboBox;

	public class FieldComboBox extends ComboBox implements IFormField
	{
		public function FieldComboBox()
		{
			super();
		}

		public function clear():void
		{
			this.selectedItem = null;
		}

		public function getValue():Object
		{
			return this.selectedItem;
		}

		public function setValue(value:Object):void
		{
			this.selectedItem = value;
		}

	}
}
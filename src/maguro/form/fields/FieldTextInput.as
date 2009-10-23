package maguro.form.fields
{
	import maguro.form.interfaces.IFormField;

	import mx.controls.TextInput;

	public class FieldTextInput extends TextInput implements IFormField
	{
		public function FieldTextInput()
		{
			super();
		}

		public function clear():void
		{
			this.text = "";
		}

		public function getValue():Object
		{
			return this.text;
		}

		public function setValue(value:Object):void
		{
			this.text = value.toString();
		}

	}
}
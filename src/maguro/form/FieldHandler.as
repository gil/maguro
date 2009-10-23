package maguro.form
{
	import maguro.form.interfaces.IFormField;

	import mx.validators.Validator;

	public class FieldHandler
	{

		public var field:IFormField;
		public var provider:Object;
		public var providerField:String;
		public var validator:Validator;

	}
}
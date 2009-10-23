package maguro.form
{
	import mx.validators.Validator;

	public class FormController
	{

		public var formFields:Array;

		public function populateFields():void
		{
			for each (var fieldHandler:FieldHandler in formFields)
			{
				var providerFields:Array = fieldHandler.providerField.split(".");
				var provider:Object = fieldHandler.provider;

				for each (var providerField:String in providerFields)
				{
					provider = provider[providerField];
				}

				fieldHandler.field.setValue(provider);
			}
		}

		public function populateProvider():void
		{
			for each (var fieldHandler:FieldHandler in formFields)
			{
				var providerFields:Array = fieldHandler.providerField.split(".");
				var provider:Object = fieldHandler.provider;

				for (var i:int = 0; i < providerFields.length - 1; i++)
				{
					provider = provider[providerFields[i]];
				}

				provider[providerFields[providerFields.length - 1]] = fieldHandler.field.getValue();
			}
		}

		public function validateField(fieldHandler:FieldHandler):Boolean
		{
			if (fieldHandler.validator != null)
			{
				fieldHandler.validator.source = fieldHandler.field;
				return (Validator.validateAll([fieldHandler.validator]).length == 0)
			}

			return true;
		}

		public function validateFields():Boolean
		{
			var valid:Boolean = true;

			for each (var fieldHandler:FieldHandler in formFields)
			{
				if (!validateField(fieldHandler))
				{
					valid = false;
				}
			}

			return valid;
		}

		public function clearFields():void
		{
			for each (var fieldHandler:FieldHandler in formFields)
			{
				fieldHandler.field.clear();
			}
		}

	}
}
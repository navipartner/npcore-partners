codeunit 6014598 "POS End Sale - Dim. Sale Stat"
{
    // NPR5.38/ANEN/20171228 CASE 298185 Functions to register stat on dimension in trans.
    // NPR5.40/TSA /20180126 CASE 303399 Using setup to dictate which action to run on view change
    // NPR5.40/TSA /20180305 CASE 303399 Refactored because action parameter storage has changed
    // NPR5.40/VB  /20180307 CASE 306347 Refactored retrieval of POS Action


    trigger OnRun()
    begin
    end;

    local procedure RegisterCountryCodeDimension(var SalePOS: Record "Sale POS")
    var
        RetailFormCode: Codeunit "Retail Form Code";
    begin
        RetailFormCode.SaleStat(SalePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150704, 'OnBeforeChangeToPaymentView', '', true, true)]
    local procedure CU_CodeunitPOSFrontEndManagement_OnBeforeChangeToPaymentView(var Sender: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session")
    var
        POSAction: Record "POS Action";
        POSSetup: Record "POS Setup";
        POSParameterValue: Record "POS Parameter Value";
    begin
        //-NPR5.40 [303399]

        POSSetup.Get ();
        if (POSSetup."OnBeforePaymentView Action" <> '') then begin
        //-NPR5.40 [306347]
        //  POSAction.GET (POSSetup."OnBeforePaymentView Action");
          if not POSSession.RetrieveSessionAction(POSSetup."OnBeforePaymentView Action",POSAction) then
            POSAction.Get (POSSetup."OnBeforePaymentView Action");
        //+NPR5.40 [306347]

          POSParameterValue.FilterParameters (POSSetup.RecordId, POSSetup.FieldNo ("OnBeforePaymentView Action"));

          if (POSParameterValue.FindSet ()) then begin
            repeat

              case POSParameterValue."Data Type" of
                POSParameterValue."Data Type"::Boolean : POSAction.SetWorkflowInvocationParameter (POSParameterValue.Name, ToBoolean (POSParameterValue.Value), Sender);
                POSParameterValue."Data Type"::Decimal : POSAction.SetWorkflowInvocationParameter (POSParameterValue.Name, ToDecimal (POSParameterValue.Value), Sender);
                POSParameterValue."Data Type"::Integer : POSAction.SetWorkflowInvocationParameter (POSParameterValue.Name, ToInteger (POSParameterValue.Value), Sender);
                POSParameterValue."Data Type"::Option  : POSAction.SetWorkflowInvocationParameter (POSParameterValue.Name, ToOption (POSParameterValue), Sender);
                else
                  POSAction.SetWorkflowInvocationParameter (POSParameterValue.Name, POSParameterValue.Value, Sender);
              end;

            until (POSParameterValue.Next () = 0);

          end;

          Sender.InvokeWorkflow (POSAction);
        end;
        //+NPR5.40 [303399]
    end;

    local procedure ToInteger(TextValue: Text) IntegerValue: Integer
    begin
        Evaluate (IntegerValue, TextValue, 9);
    end;

    local procedure ToDecimal(TextValue: Text) DecimalValue: Decimal
    begin
        Evaluate (DecimalValue, TextValue, 9);
    end;

    local procedure ToBoolean(TextValue: Text) BooleanValue: Boolean
    begin
        BooleanValue := UpperCase (TextValue) = 'TRUE';
    end;

    local procedure ToOption(POSParameterValue: Record "POS Parameter Value" temporary) OptionValue: Integer
    var
        POSActionParameter: Record "POS Action Parameter";
    begin

        if (not POSActionParameter.Get (POSParameterValue."Action Code", POSParameterValue.Name)) then
          exit (-1);

        OptionValue := POSActionParameter.GetOptionInt (POSParameterValue.Value);
    end;
}


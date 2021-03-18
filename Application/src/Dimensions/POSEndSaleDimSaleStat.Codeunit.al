codeunit 6014598 "NPR POS End Sale: Dim.SaleStat"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Front End Management", 'OnBeforeChangeToPaymentView', '', true, true)]
    local procedure CU_CodeunitPOSFrontEndManagement_OnBeforeChangeToPaymentView(var Sender: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        POSAction: Record "NPR POS Action";
        POSSetup: Record "NPR POS Setup";
        POSParameterValue: Record "NPR POS Parameter Value";
        Setup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSetup(Setup);
        Setup.GetNamedActionSetup(POSSetup);

        if (POSSetup."OnBeforePaymentView Action" <> '') then begin
            if not POSSession.RetrieveSessionAction(POSSetup."OnBeforePaymentView Action", POSAction) then
                POSAction.Get(POSSetup."OnBeforePaymentView Action");

            POSParameterValue.FilterParameters(POSSetup.RecordId, POSSetup.FieldNo("OnBeforePaymentView Action"));

            if (POSParameterValue.FindSet()) then begin
                repeat

                    case POSParameterValue."Data Type" of
                        POSParameterValue."Data Type"::Boolean:
                            POSAction.SetWorkflowInvocationParameter(POSParameterValue.Name, ToBoolean(POSParameterValue.Value), Sender);
                        POSParameterValue."Data Type"::Decimal:
                            POSAction.SetWorkflowInvocationParameter(POSParameterValue.Name, ToDecimal(POSParameterValue.Value), Sender);
                        POSParameterValue."Data Type"::Integer:
                            POSAction.SetWorkflowInvocationParameter(POSParameterValue.Name, ToInteger(POSParameterValue.Value), Sender);
                        POSParameterValue."Data Type"::Option:
                            POSAction.SetWorkflowInvocationParameter(POSParameterValue.Name, ToOption(POSParameterValue), Sender);
                        else
                            POSAction.SetWorkflowInvocationParameter(POSParameterValue.Name, POSParameterValue.Value, Sender);
                    end;
                until (POSParameterValue.Next() = 0);
            end;
            Sender.InvokeWorkflow(POSAction);
        end;
    end;

    local procedure ToInteger(TextValue: Text) IntegerValue: Integer
    begin
        Evaluate(IntegerValue, TextValue, 9);
    end;

    local procedure ToDecimal(TextValue: Text) DecimalValue: Decimal
    begin
        Evaluate(DecimalValue, TextValue, 9);
    end;

    local procedure ToBoolean(TextValue: Text) BooleanValue: Boolean
    begin
        BooleanValue := UpperCase(TextValue) = 'TRUE';
    end;

    local procedure ToOption(POSParameterValue: Record "NPR POS Parameter Value" temporary) OptionValue: Integer
    var
        POSActionParameter: Record "NPR POS Action Parameter";
    begin

        if (not POSActionParameter.Get(POSParameterValue."Action Code", POSParameterValue.Name)) then
            exit(-1);

        OptionValue := POSActionParameter.GetOptionInt(POSParameterValue.Value);
    end;
}


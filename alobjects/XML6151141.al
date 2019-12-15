xmlport 6151141 "M2 Get Budget Dimension Values"
{
    // NPR5.50/TSA /20190515 CASE 353714 Initial Version

    Caption = 'Get Budget Dimension Values';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(GetBudgetDimensionValues)
        {
            tableelement(tmpitembudgetnamerequest;"Item Budget Name")
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                fieldelement(BudgetName;TmpItemBudgetNameRequest.Name)
                {
                }
            }
            textelement(Response)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textelement(Status)
                {
                    MaxOccurs = Once;
                    textelement(ResponseCode)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(ResponseMessage)
                    {
                        MaxOccurs = Once;
                        textattribute(responsemessageid)
                        {
                            Occurrence = Optional;
                            XmlName = 'Id';
                        }
                    }
                    textelement(ExecutionTime)
                    {
                        MaxOccurs = Once;
                    }
                }
                tableelement(tmpitembudgetnameresponse;"Item Budget Name")
                {
                    MaxOccurs = Once;
                    XmlName = 'Budget';
                    UseTemporary = true;
                    fieldattribute(Name;TmpItemBudgetNameResponse.Name)
                    {
                    }
                    fieldattribute(Description;TmpItemBudgetNameResponse.Description)
                    {
                    }
                    textelement(LocationCodes)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        tableelement(location;Location)
                        {
                            MinOccurs = Zero;
                            XmlName = 'LocationCode';
                            fieldattribute(Code;Location.Code)
                            {
                            }
                            fieldattribute(Description;Location.Name)
                            {
                            }
                        }
                    }
                    tableelement(tmpglobal1;Dimension)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'GlobalDimension1';
                        UseTemporary = true;
                        fieldattribute(Code;TmpGlobal1.Code)
                        {
                        }
                        fieldattribute(Description;TmpGlobal1.Name)
                        {
                        }
                        textelement(globalvalues1)
                        {
                            MaxOccurs = Once;
                            XmlName = 'Values';
                            tableelement(tmpglobalvalue1;"Dimension Value")
                            {
                                MinOccurs = Zero;
                                XmlName = 'Value';
                                UseTemporary = true;
                                fieldattribute(Code;TmpGlobalValue1.Code)
                                {
                                }
                                fieldattribute(Description;TmpGlobalValue1.Name)
                                {
                                }
                            }
                        }
                    }
                    tableelement(tmpglobal2;Dimension)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'GlobalDimension2';
                        UseTemporary = true;
                        fieldattribute(Code;TmpGlobal2.Code)
                        {
                        }
                        fieldattribute(Description;TmpGlobal2.Name)
                        {
                        }
                        textelement(globalvalues2)
                        {
                            MaxOccurs = Once;
                            XmlName = 'Values';
                            tableelement(tmpglobalvalue2;"Dimension Value")
                            {
                                MinOccurs = Zero;
                                XmlName = 'Value';
                                UseTemporary = true;
                                fieldattribute(Code;TmpGlobalValue2.Code)
                                {
                                }
                                fieldattribute(Description;TmpGlobalValue2.Name)
                                {
                                }
                            }
                        }
                    }
                    tableelement(tmpdim1;Dimension)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'BudgetDimension1';
                        UseTemporary = true;
                        fieldattribute(Code;TmpDim1.Code)
                        {
                        }
                        fieldattribute(Description;TmpDim1.Name)
                        {
                        }
                        textelement(values1)
                        {
                            MaxOccurs = Once;
                            XmlName = 'Values';
                            tableelement(tmpdimvalue1;"Dimension Value")
                            {
                                MinOccurs = Zero;
                                XmlName = 'Value';
                                UseTemporary = true;
                                fieldattribute(Code;TmpDimValue1.Code)
                                {
                                }
                                fieldattribute(Description;TmpDimValue1.Name)
                                {
                                }
                            }
                        }
                    }
                    tableelement(tmpdim2;Dimension)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'BudgetDimension2';
                        UseTemporary = true;
                        fieldattribute(Code;TmpDim2.Code)
                        {
                        }
                        fieldattribute(Description;TmpDim2.Name)
                        {
                        }
                        textelement(values2)
                        {
                            MaxOccurs = Once;
                            XmlName = 'Values';
                            tableelement(tmpdimvalue2;"Dimension Value")
                            {
                                MinOccurs = Zero;
                                XmlName = 'Value';
                                UseTemporary = true;
                                fieldattribute(Code;TmpDimValue2.Code)
                                {
                                }
                                fieldattribute(Description;TmpDimValue2.Name)
                                {
                                }
                            }
                        }
                    }
                    tableelement(tmpdim3;Dimension)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'BudgetDimension3';
                        UseTemporary = true;
                        fieldattribute(Code;TmpDim3.Code)
                        {
                        }
                        fieldattribute(Description;TmpDim3.Name)
                        {
                        }
                        textelement(values3)
                        {
                            MaxOccurs = Once;
                            XmlName = 'Values';
                            tableelement(tmpdimvalue3;"Dimension Value")
                            {
                                MinOccurs = Zero;
                                XmlName = 'Value';
                                UseTemporary = true;
                                fieldattribute(Code;TmpDimValue3.Code)
                                {
                                }
                                fieldattribute(Description;TmpDimValue3.Name)
                                {
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnInitXmlPort()
    begin
        StartTime := Time;
    end;

    var
        StartTime: Time;

    procedure GenerateResponse()
    var
        ItemBudgetName: Record "Item Budget Name";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin

        if (not (TmpItemBudgetNameRequest.FindFirst ())) then begin
          SetError (100, 'Missing request.');
          exit;
        end;

        if (not ItemBudgetName.Get (TmpItemBudgetNameRequest."Analysis Area", TmpItemBudgetNameRequest.Name)) then begin
          SetError (101, StrSubstNo ('Salesbudget with name %1 not found.', TmpItemBudgetNameRequest.Name));
          exit;
        end;

        TmpItemBudgetNameResponse.TransferFields (ItemBudgetName, true);
        TmpItemBudgetNameResponse.Insert ();

        GeneralLedgerSetup.Get ();
        GetDimensions (GeneralLedgerSetup."Global Dimension 1 Code" ,TmpGlobal1, TmpGlobalValue1);
        GetDimensions (GeneralLedgerSetup."Global Dimension 2 Code" ,TmpGlobal2, TmpGlobalValue2);

        GetDimensions (ItemBudgetName."Budget Dimension 1 Code", TmpDim1, TmpDimValue1);
        GetDimensions (ItemBudgetName."Budget Dimension 2 Code", TmpDim2, TmpDimValue2);
        GetDimensions (ItemBudgetName."Budget Dimension 3 Code", TmpDim3, TmpDimValue3);

        ExecutionTime := StrSubstNo ('%1 (ms)', Format (Time - StartTime, 0, 9));
        ResponseCode := 'OK';
        ResponseMessage := 'Success';
        ResponseMessageId := Format (10);
    end;

    local procedure SetError(ErrorId: Integer;ErrorText: Text)
    begin
        ResponseMessage := ErrorText;
        ResponseCode := 'ERROR';
        ResponseMessageId := Format (ErrorId);
        ExecutionTime := StrSubstNo ('%1 (ms)', Format (Time - StartTime, 0, 9));
    end;

    local procedure GetDimensions("Code": Code[20];var TmpDimension: Record Dimension temporary;var TmpDimensionValue: Record "Dimension Value" temporary)
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
    begin

        if (Code <> '') then begin
          Dimension.Get (Code);
          TmpDimension.TransferFields (Dimension, true);
          TmpDimension.Insert ();
          DimensionValue.SetFilter ("Dimension Code", '=%1', Dimension.Code);
          if (DimensionValue.FindSet ()) then begin
            repeat
              TmpDimensionValue.TransferFields (DimensionValue, true);
              TmpDimensionValue.Insert ();
            until (DimensionValue.Next () = 0);
          end;
        end;
    end;
}


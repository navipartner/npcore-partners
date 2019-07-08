xmlport 6151142 "M2 Get Budget Entries"
{
    // NPR5.50/TSA /20190515 CASE 353714 Initial Version

    Caption = 'Get Budget Entries';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(GetBudgetEntries)
        {
            MaxOccurs = Once;
            tableelement(tmpitembudgetentryrequest;"Item Budget Entry")
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                fieldelement(BudgetName;TmpItemBudgetEntryRequest."Budget Name")
                {
                }
                fieldelement(CustomerNumber;TmpItemBudgetEntryRequest."Source No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(ItemNumber;TmpItemBudgetEntryRequest."Item No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(LocationCode;TmpItemBudgetEntryRequest."Location Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(GlobalDimension1;TmpItemBudgetEntryRequest."Global Dimension 1 Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(GlobalDimension2;TmpItemBudgetEntryRequest."Global Dimension 2 Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(BudgetDimension1;TmpItemBudgetEntryRequest."Budget Dimension 1 Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(BudgetDimension2;TmpItemBudgetEntryRequest."Budget Dimension 2 Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(BudgetDimension3;TmpItemBudgetEntryRequest."Budget Dimension 3 Code")
                {
                    MinOccurs = Zero;
                }
                textelement(FromDate)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(UntilDate)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
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
                    XmlName = 'Budget';
                    UseTemporary = true;
                    fieldattribute(Name;TmpItemBudgetNameResponse.Name)
                    {
                    }
                    fieldattribute(Description;TmpItemBudgetNameResponse.Description)
                    {
                    }
                    textelement(Entries)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        tableelement(tmpitembudgetentryresponse;"Item Budget Entry")
                        {
                            MaxOccurs = Unbounded;
                            MinOccurs = Zero;
                            XmlName = 'Entry';
                            UseTemporary = true;
                            fieldattribute(Date;TmpItemBudgetEntryResponse.Date)
                            {
                            }
                            fieldattribute(ItemNumber;TmpItemBudgetEntryResponse."Item No.")
                            {
                            }
                            fieldattribute(CustomerNumber;TmpItemBudgetEntryResponse."Source No.")
                            {
                            }
                            fieldattribute(Description;TmpItemBudgetEntryResponse.Description)
                            {
                            }
                            fieldattribute(Quantity;TmpItemBudgetEntryResponse.Quantity)
                            {
                            }
                            fieldattribute(CostAmount;TmpItemBudgetEntryResponse."Cost Amount")
                            {
                            }
                            fieldattribute(SalesAmount;TmpItemBudgetEntryResponse."Sales Amount")
                            {
                            }
                            fieldattribute(LocationCode;TmpItemBudgetEntryResponse."Location Code")
                            {
                                Occurrence = Optional;
                            }
                            fieldattribute(GlobalDimension1Code;TmpItemBudgetEntryResponse."Global Dimension 1 Code")
                            {
                                Occurrence = Optional;
                            }
                            fieldattribute(GlobalDimension2Code;TmpItemBudgetEntryResponse."Global Dimension 2 Code")
                            {
                                Occurrence = Optional;
                            }
                            fieldattribute(BudgetDimension1Code;TmpItemBudgetEntryResponse."Budget Dimension 1 Code")
                            {
                                Occurrence = Optional;
                            }
                            fieldattribute(BudgetDimension2Code;TmpItemBudgetEntryResponse."Budget Dimension 2 Code")
                            {
                                Occurrence = Optional;
                            }
                            fieldattribute(BudgetDimension3Code;TmpItemBudgetEntryResponse."Budget Dimension 3 Code")
                            {
                                Occurrence = Optional;
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
        ItemBudgetEntry: Record "Item Budget Entry";
        BudgetFromDate: Date;
        BudgetUntilDate: Date;
    begin
        if (not TmpItemBudgetEntryRequest.FindFirst ()) then begin
            SetError (100, 'Missing request.');
          exit;
        end;

        if (not ItemBudgetName.Get (ItemBudgetName."Analysis Area"::Sales, TmpItemBudgetEntryRequest."Budget Name")) then begin
          SetError (101, StrSubstNo ('Salesbudget with name %1 not found.', TmpItemBudgetEntryRequest."Budget Name"));
          exit;
        end;

        TmpItemBudgetNameResponse.TransferFields (ItemBudgetName, true);
        TmpItemBudgetNameResponse.Insert ();

        ItemBudgetEntry.SetFilter ("Budget Name", '=%1', TmpItemBudgetEntryRequest."Budget Name");
        if (TmpItemBudgetEntryRequest."Source No." <> '') then begin
          ItemBudgetEntry.SetFilter ("Source Type", '=%1', ItemBudgetEntry."Source Type"::Customer);
          ItemBudgetEntry.SetFilter ("Source No.", '=%1', TmpItemBudgetEntryRequest."Source No.");
        end;

        if (TmpItemBudgetEntryRequest."Item No." <> '') then
          ItemBudgetEntry.SetFilter ("Item No.", '=%1', TmpItemBudgetEntryRequest."Item No.");

        if (TmpItemBudgetEntryRequest."Location Code" <> '') then
          ItemBudgetEntry.SetFilter ("Location Code", '=%1', TmpItemBudgetEntryRequest."Location Code");

        if (TmpItemBudgetEntryRequest."Global Dimension 1 Code" <> '') then
          ItemBudgetEntry.SetFilter ("Global Dimension 1 Code", '=%1', TmpItemBudgetEntryRequest."Global Dimension 1 Code");

        if (TmpItemBudgetEntryRequest."Global Dimension 2 Code" <> '') then
          ItemBudgetEntry.SetFilter ("Global Dimension 2 Code", '=%1', TmpItemBudgetEntryRequest."Global Dimension 2 Code");

        if (TmpItemBudgetEntryRequest."Budget Dimension 1 Code" <> '') then
          ItemBudgetEntry.SetFilter ("Budget Dimension 1 Code", '=%1', TmpItemBudgetEntryRequest."Budget Dimension 1 Code");

        if (TmpItemBudgetEntryRequest."Budget Dimension 2 Code" <> '') then
          ItemBudgetEntry.SetFilter ("Budget Dimension 2 Code", '=%1', TmpItemBudgetEntryRequest."Budget Dimension 2 Code");

        if (TmpItemBudgetEntryRequest."Budget Dimension 3 Code" <> '') then
          ItemBudgetEntry.SetFilter ("Budget Dimension 3 Code", '=%1', TmpItemBudgetEntryRequest."Budget Dimension 3 Code");

        if (FromDate = '') then
          FromDate := '1900-01-01';

        if (UntilDate = '') then
          UntilDate := '2099-12-31';

        if (not Evaluate (BudgetFromDate, FromDate, 9)) then begin
          SetError (102, StrSubstNo ('FromDate does not evaluate to date of format YYYY-MM-DD.', FromDate));
          exit;
        end;

        if (not Evaluate (BudgetUntilDate, UntilDate, 9)) then begin
          SetError (103, StrSubstNo ('UntilDate does not evaluate to date of format YYYY-MM-DD.', UntilDate));
          exit;
        end;

        ItemBudgetEntry.SetFilter (Date, '%1..%2', BudgetFromDate, BudgetUntilDate);

        if (ItemBudgetEntry.FindSet ()) then begin
          repeat
            TmpItemBudgetEntryResponse.TransferFields (ItemBudgetEntry, true);
            TmpItemBudgetEntryResponse.Insert ();
          until (ItemBudgetEntry.Next () = 0);
        end;


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
}


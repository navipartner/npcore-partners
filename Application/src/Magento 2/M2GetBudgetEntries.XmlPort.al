xmlport 6151142 "NPR M2 Get Budget Entries"
{
    Caption = 'Get Budget Entries';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(GetBudgetEntries)
        {
            MaxOccurs = Once;
            tableelement(tmpitembudgetentryrequest; "Item Budget Entry")
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                fieldelement(BudgetName; TmpItemBudgetEntryRequest."Budget Name")
                {
                }
                fieldelement(CustomerNumber; TmpItemBudgetEntryRequest."Source No.")
                {
                    MinOccurs = Zero;
                }
                textelement(salespersoncode)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'SalespersonCode';
                }
                fieldelement(ItemNumber; TmpItemBudgetEntryRequest."Item No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(LocationCode; TmpItemBudgetEntryRequest."Location Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(GlobalDimension1; TmpItemBudgetEntryRequest."Global Dimension 1 Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(GlobalDimension2; TmpItemBudgetEntryRequest."Global Dimension 2 Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(BudgetDimension1; TmpItemBudgetEntryRequest."Budget Dimension 1 Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(BudgetDimension2; TmpItemBudgetEntryRequest."Budget Dimension 2 Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(BudgetDimension3; TmpItemBudgetEntryRequest."Budget Dimension 3 Code")
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
                tableelement(tmpitembudgetnameresponse; "Item Budget Name")
                {
                    XmlName = 'Budget';
                    UseTemporary = true;
                    fieldattribute(Name; TmpItemBudgetNameResponse.Name)
                    {
                    }
                    fieldattribute(Description; TmpItemBudgetNameResponse.Description)
                    {
                    }
                    textelement(Entries)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        tableelement(tmpitembudgetentryresponse; "Item Budget Entry")
                        {
                            MaxOccurs = Unbounded;
                            MinOccurs = Zero;
                            XmlName = 'Entry';
                            UseTemporary = true;
                            fieldattribute(Date; TmpItemBudgetEntryResponse.Date)
                            {
                            }
                            fieldattribute(ItemNumber; TmpItemBudgetEntryResponse."Item No.")
                            {
                            }
                            fieldattribute(CustomerNumber; TmpItemBudgetEntryResponse."Source No.")
                            {
                            }
                            textattribute(budgetsalespersoncode)
                            {
                                XmlName = 'SalespersonCode';

                                trigger OnBeforePassVariable()
                                var
                                    Customer: Record Customer;
                                begin
                                    BudgetSalespersonCode := SalesPersonCode;
                                    if (BudgetSalespersonCode = '') then
                                        if (TmpItemBudgetEntryResponse."Source Type" = TmpItemBudgetEntryResponse."Source Type"::Customer) then
                                            if (Customer.Get(TmpItemBudgetEntryResponse."Source No.")) then
                                                BudgetSalespersonCode := Customer."Salesperson Code";
                                end;
                            }
                            fieldattribute(Description; TmpItemBudgetEntryResponse.Description)
                            {
                            }
                            fieldattribute(Quantity; TmpItemBudgetEntryResponse.Quantity)
                            {
                            }
                            fieldattribute(CostAmount; TmpItemBudgetEntryResponse."Cost Amount")
                            {
                            }
                            fieldattribute(SalesAmount; TmpItemBudgetEntryResponse."Sales Amount")
                            {
                            }
                            fieldattribute(LocationCode; TmpItemBudgetEntryResponse."Location Code")
                            {
                                Occurrence = Optional;
                            }
                            fieldattribute(GlobalDimension1Code; TmpItemBudgetEntryResponse."Global Dimension 1 Code")
                            {
                                Occurrence = Optional;
                            }
                            fieldattribute(GlobalDimension2Code; TmpItemBudgetEntryResponse."Global Dimension 2 Code")
                            {
                                Occurrence = Optional;
                            }
                            fieldattribute(BudgetDimension1Code; TmpItemBudgetEntryResponse."Budget Dimension 1 Code")
                            {
                                Occurrence = Optional;
                            }
                            fieldattribute(BudgetDimension2Code; TmpItemBudgetEntryResponse."Budget Dimension 2 Code")
                            {
                                Occurrence = Optional;
                            }
                            fieldattribute(BudgetDimension3Code; TmpItemBudgetEntryResponse."Budget Dimension 3 Code")
                            {
                                Occurrence = Optional;
                            }
                        }
                    }
                }
            }
        }
    }

    trigger OnInitXmlPort()
    begin
        StartTime := Time;
    end;

    var
        StartTime: Time;
        ExecutionTimeLbl: Label '%1 (ms)', Locked = true;

    procedure GenerateResponse()
    var
        ItemBudgetName: Record "Item Budget Name";
        Customer: Record Customer;
        BudgetFromDate: Date;
        BudgetUntilDate: Date;
        SalesbudgetLbl: Label 'Salesbudget with name %1 not found.', Locked = true;
    begin
        if (not TmpItemBudgetEntryRequest.FindFirst()) then begin
            SetError(100, 'Missing request.');
            exit;
        end;

        if (not ItemBudgetName.Get(ItemBudgetName."Analysis Area"::Sales, TmpItemBudgetEntryRequest."Budget Name")) then begin
            SetError(101, StrSubstNo(SalesbudgetLbl, TmpItemBudgetEntryRequest."Budget Name"));
            exit;
        end;

        TmpItemBudgetNameResponse.TransferFields(ItemBudgetName, true);
        TmpItemBudgetNameResponse.Insert();

        if (FromDate = '') then
            FromDate := '1900-01-01';

        if (UntilDate = '') then
            UntilDate := '2099-12-31';

        if (not Evaluate(BudgetFromDate, FromDate, 9)) then begin
            SetError(102, 'FromDate does not evaluate to date of format YYYY-MM-DD.');
            exit;
        end;

        if (not Evaluate(BudgetUntilDate, UntilDate, 9)) then begin
            SetError(103, 'UntilDate does not evaluate to date of format YYYY-MM-DD.');
            exit;
        end;

        if (SalesPersonCode = '') then begin
            GetBudgetEntriesWorker(TmpItemBudgetEntryRequest."Budget Name", TmpItemBudgetEntryRequest."Source No.", TmpItemBudgetEntryRequest."Item No.", TmpItemBudgetEntryRequest."Location Code",
                                    TmpItemBudgetEntryRequest."Global Dimension 1 Code", TmpItemBudgetEntryRequest."Global Dimension 2 Code",
                                    TmpItemBudgetEntryRequest."Budget Dimension 1 Code", TmpItemBudgetEntryRequest."Budget Dimension 2 Code", TmpItemBudgetEntryRequest."Budget Dimension 3 Code",
                                    BudgetFromDate, BudgetUntilDate);
        end else begin
            Customer.SetFilter("Salesperson Code", '=%1', SalesPersonCode);
            if (Customer.FindSet()) then begin
                repeat
                    GetBudgetEntriesWorker(TmpItemBudgetEntryRequest."Budget Name", Customer."No.", TmpItemBudgetEntryRequest."Item No.", TmpItemBudgetEntryRequest."Location Code",
                                    TmpItemBudgetEntryRequest."Global Dimension 1 Code", TmpItemBudgetEntryRequest."Global Dimension 2 Code",
                                    TmpItemBudgetEntryRequest."Budget Dimension 1 Code", TmpItemBudgetEntryRequest."Budget Dimension 2 Code", TmpItemBudgetEntryRequest."Budget Dimension 3 Code",
                                    BudgetFromDate, BudgetUntilDate);
                until (Customer.Next() = 0);
            end;
        end;

        ExecutionTime := StrSubstNo(ExecutionTimeLbl, Format(Time - StartTime, 0, 9));
        ResponseCode := 'OK';
        ResponseMessage := 'Success';
        ResponseMessageId := Format(10);
    end;

    local procedure GetBudgetEntriesWorker(BudgetName: Code[10]; CustomerNo: Code[20]; ItemNo: Code[20]; LocationCode: Code[10]; GlblDim1Code: Code[20]; GlblDim2Code: Code[20]; BudgetDim1Code: Code[20]; BudgetDim2Code: Code[20]; BudgetDim3Code: Code[20]; BudgetFromDate: Date; BudgetUntilDate: Date)
    var
        ItemBudgetEntry: Record "Item Budget Entry";
    begin
        ItemBudgetEntry.SetFilter("Budget Name", '=%1', BudgetName);

        if (CustomerNo <> '') then begin
            ItemBudgetEntry.SetFilter("Source Type", '=%1', ItemBudgetEntry."Source Type"::Customer);
            ItemBudgetEntry.SetFilter("Source No.", '=%1', CustomerNo);
        end;

        if (ItemNo <> '') then
            ItemBudgetEntry.SetFilter("Item No.", '=%1', ItemNo);

        if (LocationCode <> '') then
            ItemBudgetEntry.SetFilter("Location Code", '=%1', LocationCode);

        if (GlblDim1Code <> '') then
            ItemBudgetEntry.SetFilter("Global Dimension 1 Code", '=%1', GlblDim1Code);

        if (GlblDim2Code <> '') then
            ItemBudgetEntry.SetFilter("Global Dimension 2 Code", '=%1', GlblDim2Code);

        if (BudgetDim1Code <> '') then
            ItemBudgetEntry.SetFilter("Budget Dimension 1 Code", '=%1', BudgetDim1Code);

        if (BudgetDim2Code <> '') then
            ItemBudgetEntry.SetFilter("Budget Dimension 2 Code", '=%1', BudgetDim2Code);

        if (BudgetDim3Code <> '') then
            ItemBudgetEntry.SetFilter("Budget Dimension 3 Code", '=%1', BudgetDim3Code);

        ItemBudgetEntry.SetFilter(Date, '%1..%2', BudgetFromDate, BudgetUntilDate);

        if (ItemBudgetEntry.FindSet()) then begin
            repeat
                TmpItemBudgetEntryResponse.TransferFields(ItemBudgetEntry, true);
                TmpItemBudgetEntryResponse.Insert();
            until (ItemBudgetEntry.Next() = 0);
        end;

        exit;
    end;

    local procedure SetError(ErrorId: Integer; ErrorText: Text)
    begin

        ResponseMessage := ErrorText;
        ResponseCode := 'ERROR';
        ResponseMessageId := Format(ErrorId);
        ExecutionTime := StrSubstNo(ExecutionTimeLbl, Format(Time - StartTime, 0, 9));
    end;
}
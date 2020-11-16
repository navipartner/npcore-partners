xmlport 6060081 "NPR MCS Recomm. History"
{
    // NPR5.30/BR  /20170215  CASE 252646 Object Created
    // NPR5.34/BR  /20170725  CASE 275206 Only export no's that match MCS criteria

    Caption = 'MCS Recommendations History';
    FieldDelimiter = '<None>';
    FieldSeparator = ',';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Item Ledger Entry"; "Item Ledger Entry")
            {
                XmlName = 'itemledgerentry';
                textelement(useridtext)
                {
                    XmlName = 'userid';

                    trigger OnBeforePassVariable()
                    var
                        MCSRecommendationsHandler: Codeunit "NPR MCS Recomm. Handler";
                    begin
                        if "Item Ledger Entry"."Source No." <> '' then
                            UserIDText := "Item Ledger Entry"."Source No."
                        else
                            UserIDText := "Item Ledger Entry"."Document No.";

                        //-NPR5.34 [275206]
                        UserIDText := DelChr(UserIDText, '=', ' ');
                        if not MCSRecommendationsHandler.IsValidMCSNo(UserIDText) then
                            UserIDText := '';
                        //+NPR5.34 [275206]
                    end;
                }
                fieldelement(itemid; "Item Ledger Entry"."Item No.")
                {
                }
                textelement(timestamptext)
                {
                    XmlName = 'timestamp';

                    trigger OnBeforePassVariable()
                    begin
                        TimeStampText := MCSRecServiceAPI.CreateDotNetDateTime("Item Ledger Entry"."Posting Date");
                    end;
                }
                textelement(eventtypetext)
                {
                    XmlName = 'eventtype';

                    trigger OnBeforePassVariable()
                    begin
                        EventTypeText := 'Purchase';
                    end;
                }
                textelement(textquantity)
                {
                    XmlName = 'count';

                    trigger OnBeforePassVariable()
                    begin
                        TextQuantity := Format(-"Item Ledger Entry".Quantity, 0, 9);
                    end;
                }
                textelement(unitpricetext)
                {
                    XmlName = 'unitprice';

                    trigger OnBeforePassVariable()
                    begin
                        if "Item Ledger Entry".Quantity <> 0 then
                            UnitPriceText := Format(Round("Item Ledger Entry"."Sales Amount (Actual)" / "Item Ledger Entry".Quantity, 0.01), 0, 9)
                        else
                            UnitPriceText := Format(0, 0, 9);
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    MCSRecommendationsHandler: Codeunit "NPR MCS Recomm. Handler";
                begin
                    if MCSRecommendationsModel."Item View" <> '' then begin
                        TempInventoryBuffer.SetRange("Item No.", "Item Ledger Entry"."Item No.");
                        if TempInventoryBuffer.IsEmpty then
                            currXMLport.Skip;
                    end;

                    if "Item Ledger Entry"."Source Type" = "Item Ledger Entry"."Source Type"::Customer then
                        if MCSRecommendationsModel."Customer View" <> '' then
                            if not TempCustomer.Get("Item Ledger Entry"."Source No.") then
                                currXMLport.Skip;

                    //-NPR5.34 [275206]
                    if not MCSRecommendationsHandler.IsValidMCSNo("Item Ledger Entry"."Item No.") then
                        currXMLport.Skip;
                    //+NPR5.34 [275206]

                    NumberOfLinesExported := NumberOfLinesExported + 1;
                    if (MaxNumberOfLines > 0) then begin
                        if NumberOfLinesExported > MaxNumberOfLines then begin
                            HasMoreLines := true;
                            currXMLport.Break;
                        end;
                    end;
                    LastLedgerEntryNo := "Item Ledger Entry"."Entry No.";
                end;

                trigger OnPreXmlItem()
                var
                    ItemWithinSelection: Record Item;
                    Customer: Record Customer;
                begin
                    MCSRecommendationsModel.TestField("Model ID");
                    if MCSRecommendationsModel."Item Ledger Entry View" <> '' then
                        "Item Ledger Entry".SetView(MCSRecommendationsModel."Item Ledger Entry View");
                    "Item Ledger Entry".SetRange("Entry Type", "Item Ledger Entry"."Entry Type"::Sale);

                    if LastLedgerEntryNo > 0 then
                        "Item Ledger Entry".SetFilter("Entry No.", '>%1', LastLedgerEntryNo);

                    if MCSRecommendationsModel."Item View" <> '' then begin
                        ItemWithinSelection.SetView(MCSRecommendationsModel."Item View");
                        if ItemWithinSelection.FindSet(false, false) then
                            repeat
                                TempInventoryBuffer."Item No." := ItemWithinSelection."No.";
                                TempInventoryBuffer.Insert;
                            until ItemWithinSelection.Next = 0;
                    end;

                    if MCSRecommendationsModel."Customer View" <> '' then begin
                        Customer.SetView(MCSRecommendationsModel."Customer View");
                        if Customer.FindSet then
                            repeat
                                TempCustomer."No." := Customer."No.";
                                TempCustomer.Insert;
                            until Customer.Next = 0;
                    end;

                    NumberOfLinesExported := 0;
                    HasMoreLines := false;
                end;
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

    var
        MCSRecommendationsModel: Record "NPR MCS Recomm. Model";
        LastLedgerEntryNo: Integer;
        LanguageCode: Code[10];
        LastModifiedDate: Date;
        TempInventoryBuffer: Record "Inventory Buffer" temporary;
        TempCustomer: Record Customer temporary;
        MCSRecServiceAPI: Codeunit "NPR MCS Rec. Service API";
        MaxNumberOfLines: Integer;
        NumberOfLinesExported: Integer;
        HasMoreLines: Boolean;

    procedure SetModel(ParMCSRecommendationsModel: Record "NPR MCS Recomm. Model")
    begin
        MCSRecommendationsModel := ParMCSRecommendationsModel;
    end;

    procedure SetLastLedgerEntryNo(ParEntryNo: Integer)
    begin
        LastLedgerEntryNo := ParEntryNo;
    end;

    procedure SetMaxNumberOfLines(ParMaxNumberOfLines: Integer)
    begin
        MaxNumberOfLines := ParMaxNumberOfLines;
    end;

    procedure GetLastEntryNo(): Integer
    begin
        exit(LastLedgerEntryNo);
    end;

    procedure GetHasMoreLines(): Boolean
    begin
        exit(HasMoreLines);
    end;
}


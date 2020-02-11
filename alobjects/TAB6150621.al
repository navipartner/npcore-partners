table 6150621 "POS Entry"
{
    // NPR5.29/AP/20170126 CASE 262628 Recreated ENU-captions
    // NPR5.30/AP/20170209 CASE 261728 Renamed field "Store Code" -> "POS Store Code"
    // NPR5.32/AP/20170220 CASE 262628 Renamed field "Receipt No." -> "Document No."
    // NPR5.36/BR/20170609 CASE 279551 Added fields for Item Ledger Entry Posting
    // NPR5.36/BR/20170704 CASE 279551 Added recalculation functions
    // NPR5.36/AP/20170713 CASE 262628 Added statics facts (Amounts) and "POS Ledg. Register No."
    //                                 Changes to Entry Type
    // NPR5.36/AP/20170725 CASE 279547 Removed "Posted" and "Item Entries Posted"
    //                                 Refactored Posted marking
    //                                 Added Description
    // NPR5.36/BR/20170810 CASE 277096 Filled LookupPageID and DrillDownPageID
    // NPR5.37/BR/20171024 CASE 294362 Added Entry Type option Debitsale, added fields Sales Document Type, Sales Document No.
    // NPR5.38/BR/20171108 CASE 294747 Added function ShowDimensions
    // NPR5.38/TSA /20171127  CASE 297087 Added Entry Type, System Entry
    // NPR5.38/BR  /20171214  CASE 299888 Renamed from POS Ledg. Register No. to POS Period Register No. (incl. Captions)
    // NPR5.38/BR  /20180123  CASE 303213 Added fields From External Source, External Source Name, External Source Entry No.
    // NPR5.39/BR  /20180124  CASE 302696 Changed "VAT" in field names to "Tax"
    // NPR5.39/BR  /20180208  CASE 304165 Added No. of Print Log Entries Flowfield
    // NPR5.39/BR  /20180215  CASE 305016 Added Fiscal No.
    // NPR5.40/TSA /20180228 CASE 306581 Reinstated Entry Type 4 -> Balancing
    // NPR5.40/MMV /20180319 CASE 304639 Renamed field 230
    // NPR5.42/TSA /20180511 CASE 314834 Dimensions are editable when entry is unposted
    // NPR5.48/MMV /20180606 CASE 318028 Added fields 107, 108, 240. Renamed field 230. Added "Entry Type" option: Cancelled.
    // NPR5.50/MHA /20190422 CASE 337539 Added field 170 "Retail ID"
    // NPR5.51/MMV /20190624 CASE 356076 Added field 109,111 and renamed the other totalling fields to align more with workshift total field naming.
    //                            Removed 107 that ended up being useless.
    // NPR5.53/SARA/20191024 CASE 373672 Added Field 600..650
    // NPR5.53/ALPO/20191105 CASE 376035 Added field 180 "Event No." to save info about event used on sale
    // NPR5.53/ALPO/20200108 CASE 380918 Post Seating Code and Number of Guests to POS Entries (for further sales analysis breakedown)

    Caption = 'POS Entry';
    DrillDownPageID = "POS Entries";
    LookupPageID = "POS Entries";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(3;"POS Store Code";Code[10])
        {
            Caption = 'POS Store Code';
            TableRelation = "POS Store";
        }
        field(4;"POS Unit No.";Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = "POS Unit";
        }
        field(5;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(6;"Fiscal No.";Code[20])
        {
            Caption = 'Fiscal No.';
        }
        field(7;"POS Period Register No.";Integer)
        {
            Caption = 'POS Period Register No.';
            TableRelation = "POS Period Register";
        }
        field(9;"Entry Type";Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Comment,Direct Sale,Other,Credit Sale,Balancing,Cancelled Sale';
            OptionMembers = Comment,"Direct Sale",Other,"Credit Sale",Balancing,"Cancelled Sale";
        }
        field(10;"Entry Date";Date)
        {
            Caption = 'Entry Date';
        }
        field(11;"Starting Time";Time)
        {
            Caption = 'Starting Time';
        }
        field(12;"Ending Time";Time)
        {
            Caption = 'Ending Time';
        }
        field(14;Description;Text[80])
        {
            Caption = 'Description';
        }
        field(20;"Customer No.";Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(30;"System Entry";Boolean)
        {
            Caption = 'System Entry';
        }
        field(40;"Shortcut Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
        }
        field(41;"Shortcut Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));
        }
        field(43;"Salesperson Code";Code[10])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(47;"No. Printed";Integer)
        {
            Caption = 'No. Printed';
            Editable = false;
        }
        field(52;"Post Item Entry Status";Option)
        {
            Caption = 'Post Item Entry Status';
            OptionCaption = 'Unposted,Error while Posting,Posted,Not To Be Posted';
            OptionMembers = Unposted,"Error while Posting",Posted,"Not To Be Posted";
        }
        field(53;"Post Entry Status";Option)
        {
            Caption = 'Post Entry Status';
            OptionCaption = 'Unposted,Error while Posting,Posted,Not To Be Posted';
            OptionMembers = Unposted,"Error while Posting",Posted,"Not To Be Posted";
        }
        field(54;"POS Posting Log Entry No.";Integer)
        {
            Caption = 'POS Posting Log Entry No.';
            TableRelation = "POS Posting Log";
        }
        field(60;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(61;"Document Date";Date)
        {
            Caption = 'Document Date';
        }
        field(70;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(71;"Currency Factor";Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0:15;
            Editable = false;
            InitValue = 1;
            MinValue = 1;
        }
        field(100;"Item Sales (LCY)";Decimal)
        {
            Caption = 'Item Sales (LCY)';
        }
        field(101;"Discount Amount";Decimal)
        {
            Caption = 'Discount Amount';
        }
        field(102;"Sales Quantity";Decimal)
        {
            Caption = 'Sales Quantity';
        }
        field(103;"Return Sales Quantity";Decimal)
        {
            Caption = 'Return Sales Quantity';
        }
        field(104;"Amount Excl. Tax";Decimal)
        {
            Caption = 'Amount Excl. Tax';
        }
        field(105;"Tax Amount";Decimal)
        {
            Caption = 'Tax Amount';
        }
        field(106;"Amount Incl. Tax";Decimal)
        {
            Caption = 'Amount Incl. Tax';
        }
        field(108;"No. of Sales Lines";Integer)
        {
            Caption = 'No. of Sales Lines';
        }
        field(109;"Item Returns (LCY)";Decimal)
        {
            Caption = 'Item Returns (LCY)';
        }
        field(110;"Rounding Amount (LCY)";Decimal)
        {
            Caption = 'Rounding Amount (LCY)';
        }
        field(111;"Amount Incl. Tax & Round";Decimal)
        {
            Caption = 'Amount Incl. Tax & Round';
        }
        field(114;"Tax Area Code";Code[20])
        {
            Caption = 'Tax Area Code';
            TableRelation = "Tax Area";
        }
        field(160;"POS Sale ID";Integer)
        {
            Caption = 'POS Sale ID';
        }
        field(170;"Retail ID";Guid)
        {
            Caption = 'Retail ID';
        }
        field(180;"Event No.";Code[20])
        {
            Caption = 'Active Event No.';
            Description = 'NPR5.53 [376035]';
            TableRelation = Job WHERE (Event=CONST(true));
        }
        field(200;"Customer Posting Group";Code[10])
        {
            Caption = 'Customer Posting Group';
            Editable = false;
            TableRelation = "Customer Posting Group";
        }
        field(201;"Country/Region Code";Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(202;"Transaction Type";Code[10])
        {
            Caption = 'Transaction Type';
            TableRelation = "Transaction Type";
        }
        field(203;"Transport Method";Code[10])
        {
            Caption = 'Transport Method';
            TableRelation = "Transport Method";
        }
        field(204;"Exit Point";Code[10])
        {
            Caption = 'Exit Point';
            TableRelation = "Entry/Exit Point";
        }
        field(205;"Area";Code[10])
        {
            Caption = 'Area';
            TableRelation = Area;
        }
        field(206;"Transaction Specification";Code[10])
        {
            Caption = 'Transaction Specification';
            TableRelation = "Transaction Specification";
        }
        field(207;"Prices Including VAT";Boolean)
        {
            Caption = 'Prices Including VAT';

            trigger OnValidate()
            var
                SalesLine: Record "Sales Line";
                Currency: Record Currency;
                RecalculatePrice: Boolean;
            begin
            end;
        }
        field(208;"Reason Code";Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(210;"From External Source";Boolean)
        {
            Caption = 'From External Source';
        }
        field(211;"External Source Name";Text[50])
        {
            Caption = 'External Source Name';
        }
        field(212;"External Source Entry No.";Integer)
        {
            Caption = 'External Source Entry No.';
        }
        field(230;"No. of Print Output Entries";Integer)
        {
            CalcFormula = Count("POS Entry Output Log" WHERE ("POS Entry No."=FIELD("Entry No."),
                                                              "Output Method"=CONST(Print)));
            Caption = 'No. of Print Output Entries';
            Editable = false;
            FieldClass = FlowField;
        }
        field(240;"Fiscal No. Series";Code[10])
        {
            Caption = 'Fiscal No. Series';
        }
        field(480;"Dimension Set ID";Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                //-NPR5.38 [294717]
                ShowDimensions;
                //+NPR5.38 [294717]
            end;
        }
        field(500;"Sales Document Type";Option)
        {
            Caption = 'Sales Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(501;"Sales Document No.";Code[20])
        {
            Caption = 'Sales Document No.';
            TableRelation = "Sales Header"."No." WHERE ("Document Type"=FIELD("Sales Document Type"));
        }
        field(600;"Sale Lines";Integer)
        {
            CalcFormula = Count("POS Sales Line" WHERE ("POS Entry No."=FIELD("Entry No.")));
            Caption = 'Sale Lines';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(610;"Payment Lines";Integer)
        {
            CalcFormula = Count("POS Payment Line" WHERE ("POS Entry No."=FIELD("Entry No.")));
            Caption = 'Payment Lines';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(620;"Tax Lines";Integer)
        {
            CalcFormula = Count("POS Tax Amount Line" WHERE ("POS Entry No."=FIELD("Entry No.")));
            Caption = 'Tax Lines';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(630;"Customer Sales (LCY)";Decimal)
        {
            CalcFormula = Sum("POS Sales Line"."Amount Incl. VAT" WHERE ("POS Entry No."=FIELD("Entry No."),
                                                                         Type=FILTER(Customer)));
            Caption = 'Customer Sales (LCY)';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(640;"G/L Sales (LCY)";Decimal)
        {
            CalcFormula = Sum("POS Sales Line"."Amount Incl. VAT" WHERE ("POS Entry No."=FIELD("Entry No."),
                                                                         Type=FILTER("G/L Account")));
            Caption = 'G/L Sales (LCY)';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(650;"Payment Amount";Decimal)
        {
            CalcFormula = Sum("POS Payment Line".Amount WHERE ("POS Entry No."=FIELD("Entry No.")));
            Caption = 'Payment Amount';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(710;"NPRE Number of Guests";Integer)
        {
            Caption = 'Number of Guests';
            Description = 'NPR5.53';
        }
        field(5052;"Contact No.";Code[20])
        {
            Caption = 'Contact No.';
            TableRelation = Contact;
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Retail ID")
        {
        }
        key(Key3;"POS Store Code","POS Unit No.","Document No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        POSSalesLine: Record "POS Sales Line";
        POSPaymentLine: Record "POS Payment Line";
        POSBalancingLine: Record "POS Balancing Line";
        POSEntryCommentLine: Record "POS Entry Comment Line";
        POSTaxAmountLine: Record "POS Tax Amount Line";
    begin
        POSSalesLine.SetRange("POS Entry No.","Entry No.");
        POSSalesLine.DeleteAll;
        POSPaymentLine.SetRange("POS Entry No.","Entry No.");
        POSPaymentLine.DeleteAll;
        POSBalancingLine.SetRange("POS Entry No.","Entry No.");
        POSBalancingLine.DeleteAll;
        POSEntryCommentLine.SetRange("POS Entry No.","Entry No.");
        POSEntryCommentLine.DeleteAll;
        POSTaxAmountLine.SetRange("POS Entry No.","Entry No.");
        POSTaxAmountLine.DeleteAll;
    end;

    procedure Recalculate()
    var
        POSEntryManagement: Codeunit "POS Entry Management";
        EntryModified: Boolean;
    begin
        //-NPR5.36 [279551]
        EntryModified := false;
        POSEntryManagement.RecalculatePOSEntry(Rec,EntryModified);
        OnAfterRecalculate(EntryModified);
        if EntryModified then
          Modify(true);
        //+NPR5.36 [279551]
    end;

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        //-NPR5.42 [314834]
        //-NPR5.38 [294717]
        //DimMgt.ShowDimensionSet("Dimension Set ID",STRSUBSTNO('%1 %2',TABLECAPTION,"Entry No."));
        //+NPR5.38 [294717]

        if (("Post Entry Status" = "Post Entry Status"::Posted) and ("Post Item Entry Status" = "Post Item Entry Status"::Posted)) then begin
          DimMgt.ShowDimensionSet("Dimension Set ID",StrSubstNo('%1 %2',TableCaption,"Entry No."));
        end else begin
          "Dimension Set ID" := DimMgt.EditDimensionSet ("Dimension Set ID",StrSubstNo('%1 %2',TableCaption,"Entry No."));
          Modify ();
        end;
        //+NPR5.42 [314834]
    end;

    local procedure "---Publishers"()
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterRecalculate(var Modified: Boolean)
    begin
    end;
}


table 6014404 "Report Selection Retail"
{
    // NPR3.0j,mij: tilf¢jet rapport kode til Label2. Skal have lookup til Label Lines hoved
    // NPR4.14/TS/20150818 CASE 220964 Caption for Report Type changed DK Sales Ticket-> Terminal Ticket
    // NPR4.14/JDH/20150902 CASE 221537 Option Caption changed for field Report Type.
    // NPR4.15/JDH/20150909 CASE 222525 translated to English - no documentation in code
    // NPR4.18/MMV/20151217 CASE 225584 Added fields 12, 13, 14.
    // NPR4.18/MMV/20151230 CASE 229221 Blanked "Report Type" options: Label (Single) & Byttemærke (Single) - They are deprecated.
    // NPR5.22/MMV/20160408 CASE 232067 Added "Report Type" options: "CustomerLocationOnSave" & "CustomerLocationOnTrigger"
    //                                  Added missing "Report Type" option captions.
    // NPR5.23/MMV/20160510 CASE 240211 Removed field 14.
    //                                  Added field 15.
    //                                  Added "Report Type" option: "Sign"
    // NPR5.29/MMV /20161215 CASE 253966 Added "Report Type" option: "Bin Label".
    // NPR5.29/MMV /20161215 CASE 241549 Renamed all "Report Type" options to english and deprecated several of them (renamed to blank).
    //                                   Removed field 8 "Standard Printer".
    //                                   Renamed field 9 from "Print Code" to "Print Template"
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.32/MMV /20170501 CASE 241995 Renamed option in field 1.
    // NPR5.39/MMV /20180207 CASE 304165 Added types for POS Entry prints.
    // NPR5.39/JDH /20180220 CASE 305746 Report, Dataport and Codeunit Name Extended to 249 + made non editable.
    // NPR5.40/MMV /20180328 CASE 276562 Renamed option
    // NPR5.42/ZESO/20180517 CASE 312186 Added new usage Large Balancing (POS Entry).
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj fields 3,5,9
    // NPR5.48/JDH /20181106 CASE 334560 Changed name for Data port ID / Name to XML port ID / Name. Fixed length for all objects reference
    // NPR5.50/TSA /20190423 CASE 352483 Added Report Type "Begin Workshift (POS Entry)"
    // NPR5.51/ZESO/20190711 CASE 361680 Changed Object Type to XMLPort in Object Type Filter for Field 5.
    // NPR5.55/YAHA/20191127 CASE 362312 Added Report Type "Transfer Order"
    // NPR5.55/BHR /202020713 CASE 414268 Add retail print and Price label for warehouse activity line

    Caption = 'Usage - Retail';

    fields
    {
        field(1;"Report Type";Option)
        {
            Caption = 'Report Type';
            OptionCaption = 'Sales Receipt,Register Balancing,Price Label,Signature Receipt,Gift Voucher,,Credit Voucher,,Terminal Receipt,Large Sales Receipt,,,Exchange Label,,Customer Sales Receipt,Rental,Tailor,Order,Photo Label,,,,Warranty Certificate,Shelf Label,,,,,CustomerLocationOnSave,CustomerLocationOnTrigger,Sign,Bin Label,Sales Receipt (POS Entry),Large Sales Receipt (POS Entry),Balancing (POS Entry),Sales Doc. Confirmation (POS Entry),Large Balancing (POS Entry),Begin Workshift (POS Entry),Transfer Order,Inv.PutAway Label';
            OptionMembers = "Sales Receipt","Register Balancing","Price Label","Signature Receipt","Gift Voucher",,"Credit Voucher",,"Terminal Receipt","Large Sales Receipt",,,"Exchange Label",,"Customer Sales Receipt",Rental,Tailor,"Order","Photo Label",,,,"Warranty Certificate","Shelf Label",,,,,CustomerLocationOnSave,CustomerLocationOnTrigger,Sign,"Bin Label","Sales Receipt (POS Entry)","Large Sales Receipt (POS Entry)","Balancing (POS Entry)","Sales Doc. Confirmation (POS Entry)","Large Balancing (POS Entry)","Begin Workshift (POS Entry)","Transfer Order","Inv.PutAway Label";
        }
        field(2;Sequence;Code[10])
        {
            Caption = 'Sequence';
            Numeric = true;
        }
        field(3;"Report ID";Integer)
        {
            Caption = 'Report ID';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Report));

            trigger OnValidate()
            begin
                CalcFields("Report Name");
            end;
        }
        field(4;"Report Name";Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Report),
                                                                           "Object ID"=FIELD("Report ID")));
            Caption = 'Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5;"XML Port ID";Integer)
        {
            Caption = 'XML Port ID';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(XMLport));

            trigger OnValidate()
            begin
                CalcFields("XML Port Name");
            end;
        }
        field(6;"XML Port Name";Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(XMLport),
                                                                           "Object ID"=FIELD("XML Port ID")));
            Caption = 'XML Port Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            TableRelation = Register;
        }
        field(9;"Codeunit ID";Integer)
        {
            Caption = 'Codeunit ID';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit));

            trigger OnValidate()
            begin
                CalcFields("Codeunit Name");
            end;
        }
        field(10;"Codeunit Name";Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Codeunit),
                                                                           "Object ID"=FIELD("Codeunit ID")));
            Caption = 'Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11;"Print Template";Code[20])
        {
            Caption = 'Print Template';
            TableRelation = "RP Template Header".Code;
        }
        field(12;"Filter Object ID";Integer)
        {
            Caption = 'Filter Object ID';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(13;"Record Filter";TableFilter)
        {
            Caption = 'Record Filter';

            trigger OnValidate()
            begin
                //-NPR4.18
                if Format("Record Filter") <> '' then
                  TestField("Filter Object ID");
                //+NPR4.18
            end;
        }
        field(15;Optional;Boolean)
        {
            Caption = 'Optional';
        }
    }

    keys
    {
        key(Key1;"Report Type",Sequence)
        {
        }
        key(Key2;"Report Type","Report ID","Register No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ReportSelectionRetail2: Record "Report Selection Retail";

    procedure NewRecord()
    begin
        ReportSelectionRetail2.SetRange("Report Type","Report Type");
        if ReportSelectionRetail2.FindLast and (ReportSelectionRetail2.Sequence <> '') then
          Sequence := IncStr(ReportSelectionRetail2.Sequence)
        else
          Sequence := '1';
    end;
}


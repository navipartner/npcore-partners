table 6151371 "CS Setup"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/CLVA/20180511 CASE 307239 Added field Error Invalid Barcode
    // NPR5.43/NPKNAV/20180629 CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.47/CLVA/20181011 CASE 307282 Added field "Max Records In Search Result"
    // NPR5.48/CLVA/20181113 CASE 335606 Added field "Warehouse Type"
    // NPR5.48/CLVA/20181214 CASE 335606 Added field Media Library
    // NPR5.49/TJ  /20190218 CASE 346066 Added field "Zero Def. Qty. to Handle"
    // NPR5.50/CLVA/20190304 CASE 332844 Added field "Stock-Take Template"
    // NPR5.50/CLVA/20190527 CASE 355694 Added field "Item Reclass. Jour Temp Name" and "Item Reclass. Jour Batch Name"

    Caption = 'CS Setup';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(11;"Enable Capture Service";Boolean)
        {
            Caption = 'Enable Capture Service';

            trigger OnValidate()
            var
                CSHelperFunctions: Codeunit "CS Helper Functions";
            begin
                CSHelperFunctions.PublishWebService(Rec."Enable Capture Service");
            end;
        }
        field(12;"Log Communication";Boolean)
        {
            Caption = 'Log Communication';
        }
        field(13;"Web Service Is Published";Boolean)
        {
            CalcFormula = Exist("Web Service" WHERE ("Object Type"=CONST(Codeunit),
                                                     "Service Name"=CONST('cs_service')));
            Caption = 'Web Service Is Published';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14;"Filter Worksheets by Location";Boolean)
        {
            Caption = 'Filter Worksheets by Location';
            Description = 'Filtering Worksheets by User Location';
        }
        field(15;"Error On Invalid Barcode";Boolean)
        {
            Caption = 'Error On Invalid Barcode';
            Description = 'Show alert on IOS if barcode is invalid';
        }
        field(16;"Price Calc. Customer No.";Code[20])
        {
            Caption = 'Price Calc. Customer No.';
            TableRelation = Customer;
        }
        field(17;"Max Records In Search Result";Integer)
        {
            Caption = 'Max Records In Search Result';
            InitValue = 100;
        }
        field(18;"Aggregate Stock-Take Summarize";Boolean)
        {
            Caption = 'Aggregate Stock-Take Summarize';
        }
        field(19;"Warehouse Type";Option)
        {
            Caption = 'Warehouse Type';
            OptionCaption = 'Basic,Advanced,Advanced (Bins)';
            OptionMembers = Basic," Advanced"," Advanced (Bins)";

            trigger OnValidate()
            var
                CSUIHeader: Record "CS UI Header";
            begin
                if "Warehouse Type" <> xRec."Warehouse Type" then
                  if Confirm(TXT001,true) then
                    CSUIHeader.ModifyAll("Warehouse Type","Warehouse Type",true);
            end;
        }
        field(20;"Media Library";Option)
        {
            Caption = 'Media Library';
            OptionCaption = 'Dynamics NAV,Magento';
            OptionMembers = "Dynamics NAV",Magento;
        }
        field(22;"Stock-Take Template";Code[10])
        {
            Caption = 'Stock-Take Template';
            TableRelation = "Stock-Take Template";
        }
        field(23;"Zero Def. Qty. to Handle";Boolean)
        {
            Caption = 'Zero Def. Qty. to Handle';
        }
        field(24;"Item Reclass. Jour Temp Name";Code[10])
        {
            Caption = 'Item Reclass. Jour Temp Name';
            TableRelation = "Item Journal Template";
        }
        field(25;"Item Reclass. Jour Batch Name";Code[10])
        {
            Caption = 'Item Reclass. Jour Batch Name';
            TableRelation = "Item Journal Batch".Name WHERE ("Journal Template Name"=FIELD("Item Reclass. Jour Temp Name"));
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    var
        DCHelperFunctions: Codeunit "CS Helper Functions";
        TXT001: Label 'Update Wharehouse Type on all UIs?';
}


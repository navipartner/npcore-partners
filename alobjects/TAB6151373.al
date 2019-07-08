table 6151373 "CS UI Header"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.44/CLVA/20180719 CASE 315503 Added field "Set defaults from last record"
    // NPR5.48/CLVA/20181113 CASE 335606 Added field "Warehouse Type"
    // NPR5.49/CLVA/20190327 CASE 349554 Added field "Expand Summary Items"
    // NPR5.50/CLVA/20190327 CASE 247747 Added field "Hid Fulfilled Lines"
    // NPR5.50/CLVA/20190327 CASE 347971 Added field "Add Posting Options"

    Caption = 'CS UI Header';
    LookupPageID = "CS UIs";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(11;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(12;"No. of Records in List";Integer)
        {
            Caption = 'No. of Records in List';
        }
        field(13;"Form Type";Option)
        {
            Caption = 'Form Type';
            OptionCaption = 'Card,Selection List,Data List,Data List Input', Locked=true;
            OptionMembers = Card,"Selection List","Data List","Data List Input";
        }
        field(14;"Expand Summary Items";Boolean)
        {
            Caption = 'Expand Summary Items';
        }
        field(15;"Start UI";Boolean)
        {
            Caption = 'Start UI';

            trigger OnValidate()
            var
                MiniformHeader: Record "CS UI Header";
            begin
                MiniformHeader.SetFilter(Code,'<>%1',Code);
                MiniformHeader.SetRange("Start UI",true);
                if MiniformHeader.FindFirst then
                  Error(Text002);
            end;
        }
        field(16;"Hid Fulfilled Lines";Boolean)
        {
            Caption = 'Hid Fulfilled Lines';
        }
        field(17;"Add Posting Options";Boolean)
        {
            Caption = 'Add Posting Options';
        }
        field(19;"Warehouse Type";Option)
        {
            Caption = 'Warehouse Type';
            OptionCaption = 'Basic,Advanced,Advanced (Bins)';
            OptionMembers = Basic,Advanced,"Advanced (Bins)";
        }
        field(20;"Handling Codeunit";Integer)
        {
            Caption = 'Handling Codeunit';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Codeunit));
        }
        field(21;"Next UI";Code[20])
        {
            Caption = 'Next UI';
            TableRelation = "CS UI Header";

            trigger OnValidate()
            begin
                if "Next UI" = Code then
                  Error(Text000);

                if "Form Type" in ["Form Type"::"Selection List","Form Type"::"Data List Input"] then
                  Error(Text001,FieldCaption("Form Type"),"Form Type");
            end;
        }
        field(22;"Set defaults from last record";Boolean)
        {
            Caption = 'Set defaults from last record';
        }
        field(25;XMLin;BLOB)
        {
            Caption = 'XMLin';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        CSSetup: Record "CS Setup";
    begin
        //-NPR5.48 [335606]
        if CSSetup.FindFirst then
          "Warehouse Type" := CSSetup."Warehouse Type";
        //+NPR5.48 [335606]
    end;

    var
        Text000: Label 'Recursion is not allowed.';
        Text001: Label '%1 must not be %2.';
        Text002: Label 'There can only be one login form.';

    procedure SaveXMLin(DOMxmlin: DotNet XmlDocument)
    var
        InStrm: InStream;
    begin
        XMLin.CreateInStream(InStrm);
        DOMxmlin.Save(InStrm);
    end;

    procedure LoadXMLin(var DOMxmlin: DotNet XmlDocument)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        OutStrm: OutStream;
    begin
        XMLin.CreateOutStream(OutStrm);
        XMLDOMManagement.LoadXMLDocumentFromOutStream(OutStrm,DOMxmlin);
    end;
}


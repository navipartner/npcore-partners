table 6151390 "CS Stock-Take Handling Rfid"
{
    // NPR5.50/CLVA/20190207 CASE 344466 Object created - NP Capture Service
    // NPR5.54/CLVA/20200214 CASE 389224 Added field "Stock-Take Id" and Area
    // NPR5.54/CLVA/20200227 CASE 389224 Added key Created

    Caption = 'CS Stock-Take Handling Rfid';

    fields
    {
        field(1;Id;Guid)
        {
            Caption = 'Id';
        }
        field(10;"Stock-Take Id";Guid)
        {
            Caption = 'Stock-Take Id';
        }
        field(11;"Batch Id";Guid)
        {
            Caption = 'Batch Id';
        }
        field(12;"Request Data";BLOB)
        {
            Caption = 'Request Data';
        }
        field(13;"Request Function";Text[30])
        {
            Caption = 'Request Function';
            Editable = false;
        }
        field(14;"Response Data";BLOB)
        {
            Caption = 'Response Data';
        }
        field(15;"Batch No.";Integer)
        {
            Caption = 'Batch No.';
        }
        field(16;"Device Id";Code[10])
        {
            Caption = 'Device Id';
        }
        field(17;"Stock-Take Config Code";Code[10])
        {
            Caption = 'Stock-Take Conf. Code';
            TableRelation = "Stock-Take Configuration".Code;
        }
        field(18;"Worksheet Name";Code[10])
        {
            Caption = 'Worksheet Name';
            TableRelation = "Stock-Take Worksheet".Name WHERE ("Stock-Take Config Code"=FIELD("Stock-Take Config Code"));
        }
        field(19;Tags;Integer)
        {
            Caption = 'Tags';
        }
        field(20;Handled;Boolean)
        {
            Caption = 'Handled';
        }
        field(21;Created;DateTime)
        {
            Caption = 'Created';
        }
        field(22;"Created By";Code[20])
        {
            Caption = 'Created By';
        }
        field(23;"Batch Posting";Boolean)
        {
            Caption = 'Batch Posting';
        }
        field(24;"Posting Started";DateTime)
        {
            Caption = 'Posting Started';
        }
        field(25;"Posting Ended";DateTime)
        {
            Caption = 'Posting Ended';
        }
        field(26;"Posting Error";Text[100])
        {
            Caption = 'Posting Error';
        }
        field(27;"Posting Error Detail";Text[250])
        {
            Caption = 'Posting Error Detail';
        }
        field(28;"Area";Option)
        {
            Caption = 'Area';
            OptionCaption = 'Warehouse,Salesfloor,Stockroom';
            OptionMembers = Warehouse,Salesfloor,Stockroom;
        }
    }

    keys
    {
        key(Key1;Id)
        {
        }
        key(Key2;Created)
        {
        }
    }

    fieldgroups
    {
    }
}


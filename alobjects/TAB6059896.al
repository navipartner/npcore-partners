table 6059896 "Data Log Subscriber"
{
    // DL1.00/MH/20140801  NP-AddOn: Data Log
    //   - This Table contains information of Data Log consumers. Update of Subscribers is not mandatory and should be maintained manually.
    // DL1.01/MH/20140820 Added Field 100 "Direct Data Processing" - defines whether the Data Processing Codeunit should be executed on Runtime.
    //   - Added Field 110 "Data Processing Codeunit ID".
    // DL1.02/MH/20140820 Removed reference to Local function, LoadMonTables as Subscriber has now be omitted from the function..
    // DL1.03/MH/20140909  CASE 184907 Added Last Date Modified
    //   - Deleted Code from DL1.01 and DL1.02.
    // DL1.04/MH/20141017  CASE 187739 Added Lookup- and DrillDown Page
    // DL1.05/MH/20141128  CASE 188079 Added Key: "Last Log Entry No."
    // DL1.07/MH/20150515  CASE 214248 Removed TableRelation on field 1 Code
    // DL1.10/MHA/20160412 CASE 239117 Added field 3 Company Name to Primary Key

    Caption = 'Data Log Subscriber';
    DrillDownPageID = "Data Log Subscribers";
    LookupPageID = "Data Log Subscribers";

    fields
    {
        field(1;"Code";Code[30])
        {
            Caption = 'Code';
            Description = 'DL1.07';
        }
        field(2;"Table ID";Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(3;"Company Name";Text[30])
        {
            Caption = 'Company Name';
            Description = 'DL1.10';
            TableRelation = Company;
        }
        field(5;"Table Name";Text[30])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Table),
                                                                           "Object ID"=FIELD("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10;"Last Log Entry No.";BigInteger)
        {
            Caption = 'Last Log Entry No.';
        }
        field(100;"Direct Data Processing";Boolean)
        {
            Caption = 'Direct Data Processing';
            Description = 'DL1.01';
        }
        field(110;"Data Processing Codeunit ID";Integer)
        {
            Caption = 'Data Processing Codeunit ID';
            Description = 'DL1.01';
        }
        field(115;"Data Processing Codeunit Name";Text[30])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Codeunit),
                                                                           "Object ID"=FIELD("Data Processing Codeunit ID")));
            Caption = 'Data Processing Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120;"Last Date Modified";DateTime)
        {
            Caption = 'Last Date Modified';
            Description = 'DL1.03';
            Editable = false;
        }
    }

    keys
    {
        key(Key1;"Code","Table ID","Company Name")
        {
        }
        key(Key2;"Last Log Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure AddAsSubscriber(SubscriberCode: Code[10];TableNo: Integer)
    begin
        if Get(SubscriberCode, TableNo) then
          exit;

        Init;
        Code := SubscriberCode;
        "Table ID" := TableNo;
        "Last Log Entry No." := 0;
        Insert;
    end;
}


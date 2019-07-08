table 6059889 "Npm View"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager

    Caption = 'Npm View';
    DataPerCompany = false;
    DrillDownPageID = "Npm Views";
    LookupPageID = "Npm Views";

    fields
    {
        field(1;"Table No.";Integer)
        {
            BlankZero = true;
            Caption = 'Table No.';
            NotBlank = true;
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));

            trigger OnValidate()
            begin
                if Code = '' then begin
                  CalcFields("Table Name");
                  Code := CopyStr(DelChr("Table Name",'=',' '),1,8);
                end;
            end;
        }
        field(5;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(100;"Table Name";Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Table),
                                                             "Object ID"=FIELD("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110;"Mandatory Field Qty.";Integer)
        {
            BlankZero = true;
            CalcFormula = Count("Npm Field" WHERE (Type=CONST(Mandatory),
                                                   "Table No."=FIELD("Table No."),
                                                   "View Code"=FIELD(Code)));
            Caption = 'Mandatory Field Qty.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(115;"Field Caption Qty.";Integer)
        {
            BlankZero = true;
            CalcFormula = Count("Npm Field" WHERE (Type=CONST(Caption),
                                                   "Table No."=FIELD("Table No."),
                                                   "View Code"=FIELD(Code)));
            Caption = 'Field Caption Qty.';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Table No.","Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"Table No.","Table Name")
        {
        }
    }

    trigger OnDelete()
    var
        NpmField: Record "Npm Field";
        NpmViewField: Record "Npm View Condition";
    begin
        if IsTemporary then
          exit;

        NpmField.SetRange("Table No.","Table No.");
        NpmField.SetRange("View Code",Code);
        NpmField.DeleteAll;

        NpmViewField.SetRange("Table No.","Table No.");
        NpmViewField.SetRange("View Code",Code);
        NpmViewField.DeleteAll;
    end;

    trigger OnRename()
    var
        NpmField: Record "Npm Field";
        NpmFieldCaption: Record "Npm Field Caption";
        NpmPageView: Record "Npm Page View";
        NpmViewField: Record "Npm View Condition";
    begin
        if IsTemporary then
          exit;

        NpmField.SetRange("Table No.",xRec."Table No.");
        NpmField.SetRange("View Code",xRec.Code);
        if not NpmField.IsEmpty then begin
          NpmField.FindSet;
          repeat
            NpmField.Rename(NpmField.Type,"Table No.",Code,NpmField."Field No.");
          until NpmField.Next = 0;
        end;

        NpmFieldCaption.SetRange("Table No.",xRec."Table No.");
        NpmFieldCaption.SetRange("View Code",xRec.Code);
        if not NpmFieldCaption.IsEmpty then begin
          NpmFieldCaption.FindSet;
          repeat
            NpmFieldCaption.Rename("Table No.",Code,NpmField."Field No.",NpmFieldCaption."Language Id");
          until NpmFieldCaption.Next = 0;
        end;

        NpmViewField.SetRange("Table No.","Table No.");
        NpmViewField.SetRange("View Code",Code);
        if not NpmViewField.IsEmpty then begin
          NpmViewField.FindSet;
          repeat
            NpmViewField.Rename("Table No.",Code,NpmViewField."Field No.");
          until NpmViewField.Next = 0;
        end;

        if xRec."Table No." <> Rec."Table No." then begin
          NpmPageView.SetRange("Source Table No.",xRec."Table No.");
          NpmPageView.SetRange("View Code",xRec.Code);
          NpmPageView.DeleteAll;
        end;
        NpmPageView.SetRange("Source Table No.",Rec."Table No.");
        NpmPageView.SetRange("View Code",xRec.Code);
        if not NpmPageView.IsEmpty then begin
          NpmPageView.FindSet;
          repeat
            NpmPageView.Rename(NpmPageView."Page ID",Code);
          until NpmPageView.Next = 0;
        end;
    end;
}


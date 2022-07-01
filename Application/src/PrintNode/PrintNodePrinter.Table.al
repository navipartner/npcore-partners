﻿table 6151221 "NPR PrintNode Printer"
{
    Access = Internal;
    Caption = 'PrintNode Printer';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR PrintNode Printer List";
    LookupPageID = "NPR PrintNode Printer List";

    fields
    {
        field(1; Id; Code[20])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
            trigger OnLookup()
            var
                PrintNodeMgt: Codeunit "NPR PrintNode Mgt.";
                PrinterId: Text;
                PrinterName: Text;
            begin
                if PrintNodeMgt.LookupPrinterIdAndName(PrinterId, PrinterName) then begin
                    Id := PrinterId;
                    Name := CopyStr(PrinterName, 1, MaxStrLen(Name));
                end;
            end;
        }
        field(2; "Object Type"; Option)
        {
            Caption = 'Object Type';
            OptionMembers = Report,Codeunit;
            OptionCaption = 'Report,Codeunit';
            DataClassification = CustomerContent;
        }
        field(3; "Object ID"; Integer)
        {
            Caption = 'Object ID';
            TableRelation = if ("Object Type" = const(Codeunit)) AllObj."Object ID" where("Object Type" = const(Codeunit)) else
            if ("Object Type" = const(Report)) AllObj."Object ID" where("Object Type" = const(Report));
            DataClassification = CustomerContent;
        }
        field(10; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "BC Paper Source"; Enum "Printer Paper Source Kind")
        {
            Caption = 'Paper Source sent to Business Central reporting engine';
            InitValue = "AutomaticFeed";
            DataClassification = CustomerContent;
        }
        field(40; "BC Paper Size"; Enum "Printer Paper Kind")
        {
            Caption = 'Paper Size sent to Business Central reporting engine';
            InitValue = "A4";
            DataClassification = CustomerContent;
        }
        field(100; Settings; Blob)
        {
            Caption = 'Settings';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Id, "Object Type", "Object ID")
        {
        }
    }

    fieldgroups
    {
    }
}


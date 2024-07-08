﻿table 6150617 "NPR POS Payment Bin"
{
    Caption = 'POS Payment Bin';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Payment Bins";
    LookupPageID = "NPR POS Payment Bins";

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
        }
        field(6; "Attached to POS Unit No."; Code[10])
        {
            Caption = 'Attached to POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Open,Closed,Being Counted';
            OptionMembers = OPEN,CLOSED,BEINGCOUNTED;
        }
        field(30; "Eject Method"; Code[20])
        {
            Caption = 'Eject Method';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
                SelectedMethod: Text;
            begin
                //-NPR5.40 [300600]
                if POSPaymentBinInvokeMgt.LookupInvokeMethods(Rec, SelectedMethod) then
                    Validate("Eject Method", SelectedMethod);
                //+NPR5.40 [300600]
            end;

            trigger OnValidate()
            var
                POSPaymentBinInvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
            begin
                //-NPR5.40 [300600]
                if (Rec."Eject Method" <> xRec."Eject Method") and (xRec."Eject Method" <> '') then begin
                    POSPaymentBinInvokeParameter.SetRange("Bin No.", "No.");
                    POSPaymentBinInvokeParameter.DeleteAll();
                end;
                //+NPR5.40 [300600]
            end;
        }
        field(40; "Bin Type"; Option)
        {
            Caption = 'Bin Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Cash Drawer,Bank,Safe,Virtual';
            OptionMembers = CASH_DRAWER,BANK,SAFE,VIRTUAL;
        }

        field(50; "Suppress EOD Posting"; Boolean)
        {
            Caption = 'Suppress EOD Posting';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "No.", Description, "Eject Method")
        {

        }
    }

    trigger OnDelete()
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
        POSPaymentBinInvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
    begin
        POSPostingSetup.SetRange("POS Payment Bin Code", "No.");
        POSPostingSetup.DeleteAll(true);

        //-NPR5.40 [300660]
        POSPaymentBinInvokeParameter.SetRange("Bin No.", "No.");
        POSPaymentBinInvokeParameter.DeleteAll(true);
        //+NPR5.40 [300660]
    end;
}


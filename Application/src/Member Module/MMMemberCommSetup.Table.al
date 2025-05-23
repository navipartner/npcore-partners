﻿table 6151187 "NPR MM Member Comm. Setup"
{
    Access = Internal;

    Caption = 'Member Communication Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR MM Member Comm. Setup";
    LookupPageID = "NPR MM Member Comm. Setup";

    fields
    {
        field(1; "Membership Code"; Code[20])
        {
            Caption = 'Membership Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR MM Membership Setup";
        }
        field(3; "Message Type"; Option)
        {
            Caption = 'Message Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Welcome,Renew,Newsletter,Member Card,Tickets';
            OptionMembers = WELCOME,RENEW,NEWSLETTER,MEMBERCARD,TICKETS;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Preferred Method"; Option)
        {
            Caption = 'Preferred Method';
            DataClassification = CustomerContent;
            OptionCaption = 'Member Preferred,SMS,E-Mail,Wallet (SMS),Wallet (E-Mail)';
            OptionMembers = MEMBER,SMS,EMAIL,WALLET_SMS,WALLET_EMAIL;
        }
        field(30; "Notification Engine"; Option)
        {
            Caption = 'Notification Engine';
            DataClassification = CustomerContent;
            OptionCaption = 'Native, M2 E-Mail';
            OptionMembers = NATIVE,M2_EMAILER;
        }
        field(31; "Sender Template"; BLOB)
        {
            Caption = 'Sender Template';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Membership Code", "Message Type")
        {
        }
    }

    fieldgroups
    {
    }
}


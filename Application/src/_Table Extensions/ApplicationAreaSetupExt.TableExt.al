tableextension 6014680 "NPR Application Area Setup Ext" extends "Application Area Setup"
{
    fields
    {
        field(6060100; "NPR Ticket Essential"; Boolean)
        {
            Caption = 'NaviPartner Ticket Essential';
            DataClassification = CustomerContent;
        }
        field(6060101; "NPR Ticket Advanced"; Boolean)
        {
            Caption = 'NaviPartner Ticket Advanced';
            DataClassification = CustomerContent;
        }
        field(6060102; "NPR Ticket Wallet"; Boolean)
        {
            Caption = 'NaviPartner Ticket Wallet';
            DataClassification = CustomerContent;
        }
        field(6060103; "NPR Ticket Dynamic Price"; Boolean)
        {
            Caption = 'NaviPartner Ticket Dynamic Price';
            DataClassification = CustomerContent;
        }
        field(6060104; "NPR Retail"; Boolean)
        {
            Caption = 'NaviPartner Retail';
            DataClassification = CustomerContent;
        }
        field(6060105; "NPR NaviConnect"; Boolean)
        {
            Caption = 'NaviPartner NaviConnect';
            DataClassification = CustomerContent;
        }
        field(6060106; "NPR Membership Essential"; Boolean)
        {
            Caption = 'NaviPartner Membership Essential';
            DataClassification = CustomerContent;
        }
        field(6060107; "NPR Membership Advanced"; Boolean)
        {
            Caption = 'NaviPartner Membership Advanced';
            DataClassification = CustomerContent;
        }
        field(6060108; "NPR HeyLoyalty"; Boolean)
        {
            Caption = 'NaviPartner HeyLoyalty Integration';
            DataClassification = CustomerContent;
        }
        field(6060109; "NPR RS Local"; Boolean)
        {
            Caption = 'NaviPartner RS Localization';
            DataClassification = CustomerContent;
        }
        field(6060110; "NPR RS R Local"; Boolean)
        {
            Caption = 'NaviPartner RS Retail Localization';
            DataClassification = CustomerContent;
        }
        field(6060111; "NPR RS Fiscal"; Boolean)
        {
            Caption = 'NaviPartner RS Fiscalisation';
            DataClassification = CustomerContent;
        }
        field(6060112; "NPR CRO Fiscal"; Boolean)
        {
            Caption = 'NaviPartner CRO Fiscalization';
            DataClassification = CustomerContent;
        }
        field(6060113; "NPR NO Fiscal"; Boolean)
        {
            Caption = 'NaviPartner NO Fiscalisation';
            DataClassification = CustomerContent;
        }
        field(6060114; "NPR SI Fiscal"; Boolean)
        {
            Caption = 'NaviPartner SI Fiscalisation';
            DataClassification = CustomerContent;
        }
        field(6060115; "NPR BG Fiscal"; Boolean)
        {
            Caption = 'NaviPartner BG Fiscalisation';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR28.0';
            ObsoleteReason = 'SIS Integration specific field is introduced.';
        }
        field(6060116; "NPR BG SIS Fiscal"; Boolean)
        {
            Caption = 'NaviPartner BG SIS Fiscalisation';
            DataClassification = CustomerContent;
        }
        field(6060117; "NPR IT Fiscal"; Boolean)
        {
            Caption = 'NaviPartner IT Fiscalization';
            DataClassification = CustomerContent;
        }
    }
}
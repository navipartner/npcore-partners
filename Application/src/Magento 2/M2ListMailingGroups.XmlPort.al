xmlport 6151139 "NPR M2 List Mailing Groups"
{
    Caption = 'List Mailing Groups';
    Direction = Export;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(MailGroups)
        {
            tableelement(mailgrp; "Mailing Group")
            {
                MinOccurs = Zero;
                XmlName = 'MailGroup';
                fieldattribute(Code; MailGrp.Code)
                {
                }
                fieldattribute(Description; MailGrp.Description)
                {
                }
                textattribute(IsMember)
                {
                    Occurrence = Optional;

                    trigger OnBeforePassVariable()
                    var
                        ContactMailingGroup: Record "Contact Mailing Group";
                    begin

                        if (ContactNo <> '') then
                            IsMember := Format(ContactMailingGroup.Get(ContactNo, MailGrp.Code), 0, 9);
                    end;
                }
            }
        }
    }

    var
        ContactNo: Code[20];

    procedure CreateListForContact(CheckContactNo: Code[20])
    begin

        ContactNo := CheckContactNo;
    end;
}
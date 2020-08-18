pageextension 6014481 pageextension6014481 extends "Resource Card" 
{
    // NPR5.29/TJ/20161013 CASE 248723 New field E-Mail
    // NPR5.32/TJ/20170519 CASE 275966 New field Over Capacitate Resource
    // NPR5.34/TJ/20170725 CASE 275991 New field E-Mail Password
    // NPR5.38/TJ/20171027 CASE 285194 Removed field "E-Mail Password"
    layout
    {
        addafter("Time Sheet Approver User ID")
        {
            field("Over Capacitate Resource";"Over Capacitate Resource")
            {
            }
        }
        addafter("Employment Date")
        {
            field("E-Mail";"E-Mail")
            {
            }
        }
    }
}


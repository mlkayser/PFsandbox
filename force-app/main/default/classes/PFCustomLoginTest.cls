@isTest
private class PFCustomLoginTest
{
	@isTest
	static void PFCustomLogin()
	{
        PFCustomLoginController l_controller = new PFCustomLoginController();
        l_controller.forwardToCustomAuthPage();
        l_controller.login();
	}
}
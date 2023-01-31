describe("Signup", () => {
  beforeEach(() => {
    cy.visit("/signup");
  });

  // nomal scenario
  it("normal", () => {
    cy.get('input[name="email"]').type("hoge@hoge.com");
    cy.get('input[name="confirmEmail"]').type("hoge@hoge.com");
    cy.get('input[name="password"]').type(`TestTest!1`);
    cy.get('input[name="confirmPassword"]').type(`TestTest!1`);
    cy.get('input[name="acceptTerms"]').check();
    cy.get('button[type="submit"]').click({ force: true });
    cy.get('button[type="submit"]').click();
    cy.contains("OK").click();
    cy.url().should("include", "/");
  });
});

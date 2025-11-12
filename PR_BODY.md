# Upgrade to Java 21 (branch: upgrade/java-21)

Summary
-------
This PR upgrades the backend to target Java 21 and updates Spring Boot and Jakarta dependencies to be compatible with the newer Java/Jakarta platform.

High level changes
- Set project `java.version` to 21 and configured `maven-compiler-plugin` with `<release>21>` in `backend/pom.xml`.
- Upgraded Spring Boot parent to `3.2.12` to support Jakarta APIs and modern Java.
- Migrated JPA imports from `javax.persistence.*` to `jakarta.persistence.*` in model classes.
- Added missing getters/setters that were placeholders to ensure correct compilation.
- Added a `.gitignore` and removed built artifacts from the commit (clean commit without `backend/target`).
- Updated `START_HERE.md` to mention Java 21 as a required tool.

Files changed (high level)
- `backend/pom.xml` — Java version and Spring Boot parent upgrade; maven-compiler-plugin set to release 21.
- `backend/src/main/java/com/ganesh/helpdesk/model/*.java` — Jakarta imports and getters/setters.
- `START_HERE.md` — documented Java 21 requirement.
- `.gitignore` — excludes `backend/target/` and common build artifacts.
- `PR_BODY.md` — this file.

Why
---
Java 21 is the current LTS and provides performance, security, and language improvements. Spring Boot 3.x requires Jakarta EE package names (jakarta.*). Upgrading keeps the project supported and more secure.

Validation performed
--------------------
- `mvn -DskipTests package` — build succeeded locally.
- `mvn test` — ran (no tests present / none executed).
- Manual code inspection and small fixes applied to enable compilation.

Run / Test instructions
----------------------
1. Install JDK 21 (recommended) or use a newer JDK (build may work with newer JDKs but use 21 for parity).
2. From repo root:
```powershell
cd backend
mvn spring-boot:run
```
3. In another PowerShell window run the provided test script:
```powershell
cd C:\OneDrive\Documents\helpdesk-automation-system
.\test-endpoints.ps1
```

Notes & follow-ups
------------------
- Consider running full integration tests or QA flows against deployed environments.
- Optionally run a dependency CVE scan (I can run `mvn dependency:check` or a similar plugin if you want).
- If you prefer a different Spring Boot 3.x version, I can update to that (may require additional dependency changes).

Checklist
- [ ] Confirm CI (GitHub Actions) builds successfully on this branch.
- [ ] Run functional API tests.
- [ ] Merge into `main` after review.

If you want, I can open the PR on GitHub automatically if you provide a GitHub token, or you can paste this body when creating the PR in the web UI.

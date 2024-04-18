---
name: Dependency upgrade
about: Upgrading the version of a system dependency
title: 'Upgrade to [INSERT DEPENDENCY HERE] [INSERT VERSION NUMBER HERE]'
labels: maintenance
assignees: ''

---

- [ ] Add the new version to CircleCI
- [ ] Add the new version to .tool-versions
- [ ] Fix any failing tests or dependency issues caused by upgrade
- [ ] Provision staging box to use the new version
- [ ] Deploy code that works with the new version to staging
- [ ] Manually test on staging box with the new version
- [ ] Provision new boxes or use [this process to upgrade and deploy in place](https://docs.google.com/document/d/1qedt3nKl9nlSmYepT5DPYVcfDB9xvE81Qllmw_cYvf0/edit)
- [ ] Update this issue template with anything we need to keep in mind for the next upgrade

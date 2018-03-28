# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v4.0.0](https://github.com/voxpupuli/puppet-gluster/tree/v4.0.0) (2018-03-28)

[Full Changelog](https://github.com/voxpupuli/puppet-gluster/compare/v3.0.0...v4.0.0)

**Breaking changes:**

- Add support for gluster 3.10-312; Set default version 3.8-\>3.12 [\#143](https://github.com/voxpupuli/puppet-gluster/pull/143) ([bastelfreak](https://github.com/bastelfreak))
- Add support for Debian 9, drop debian 8 [\#139](https://github.com/voxpupuli/puppet-gluster/pull/139) ([bastelfreak](https://github.com/bastelfreak))
- replace validate\_hash with assert\_type [\#115](https://github.com/voxpupuli/puppet-gluster/pull/115) ([bastelfreak](https://github.com/bastelfreak))
- replace validate\_\* calls with datatypes [\#114](https://github.com/voxpupuli/puppet-gluster/pull/114) ([bastelfreak](https://github.com/bastelfreak))
- replace all validate functions with datatypes [\#107](https://github.com/voxpupuli/puppet-gluster/pull/107) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Enhance tests [\#113](https://github.com/voxpupuli/puppet-gluster/pull/113) ([bastelfreak](https://github.com/bastelfreak))
- Add acceptance [\#106](https://github.com/voxpupuli/puppet-gluster/pull/106) ([martialblog](https://github.com/martialblog))

**Fixed bugs:**

- Arbiter setting not being correctly passed. [\#151](https://github.com/voxpupuli/puppet-gluster/issues/151)
- Fix repo url for 3.12 in stretch [\#159](https://github.com/voxpupuli/puppet-gluster/pull/159) ([NITEMAN](https://github.com/NITEMAN))
- fix argument passing of arbiter option [\#150](https://github.com/voxpupuli/puppet-gluster/pull/150) ([sammcj](https://github.com/sammcj))

**Closed issues:**

- Gluster Volume Error [\#152](https://github.com/voxpupuli/puppet-gluster/issues/152)
- Systemd start for glusterfs-server failed! [\#146](https://github.com/voxpupuli/puppet-gluster/issues/146)
- module mount not working [\#145](https://github.com/voxpupuli/puppet-gluster/issues/145)
- globbing in apt.pp fails with gluster release 3.10 and newer [\#140](https://github.com/voxpupuli/puppet-gluster/issues/140)
- Add support for arbiter volumes [\#134](https://github.com/voxpupuli/puppet-gluster/issues/134)
- Update puppetlabs/apt dependencie [\#129](https://github.com/voxpupuli/puppet-gluster/issues/129)
- Apt public key for gluster.org changed address [\#102](https://github.com/voxpupuli/puppet-gluster/issues/102)

**Merged pull requests:**

- bump puppet to latest supported version 4.10.0 [\#160](https://github.com/voxpupuli/puppet-gluster/pull/160) ([bastelfreak](https://github.com/bastelfreak))
- Use docker\_sets in travis.yml [\#158](https://github.com/voxpupuli/puppet-gluster/pull/158) ([ekohl](https://github.com/ekohl))
- increase spec test coverage [\#157](https://github.com/voxpupuli/puppet-gluster/pull/157) ([bastelfreak](https://github.com/bastelfreak))
- Drop Debian 8 acceptance tests [\#155](https://github.com/voxpupuli/puppet-gluster/pull/155) ([juniorsysadmin](https://github.com/juniorsysadmin))
- Add support for arbiter volumes [\#133](https://github.com/voxpupuli/puppet-gluster/pull/133) ([sammcj](https://github.com/sammcj))
- make the code compatible with strict\_variables [\#132](https://github.com/voxpupuli/puppet-gluster/pull/132) ([tequeter](https://github.com/tequeter))
- update dependency for puppetlabs-apt [\#130](https://github.com/voxpupuli/puppet-gluster/pull/130) ([TheMeier](https://github.com/TheMeier))
- Fix/types: Fix signature of gluster::volume [\#119](https://github.com/voxpupuli/puppet-gluster/pull/119) ([ntnn](https://github.com/ntnn))
- release 3.0.0 [\#105](https://github.com/voxpupuli/puppet-gluster/pull/105) ([bastelfreak](https://github.com/bastelfreak))

## [v3.0.0](https://github.com/voxpupuli/puppet-gluster/tree/v3.0.0) (2017-02-12)

[Full Changelog](https://github.com/voxpupuli/puppet-gluster/compare/v2.3.0...v3.0.0)

**Implemented enhancements:**

- Repo refactor [\#103](https://github.com/voxpupuli/puppet-gluster/pull/103) ([martialblog](https://github.com/martialblog))

**Merged pull requests:**

- release 2.3.0 [\#99](https://github.com/voxpupuli/puppet-gluster/pull/99) ([bastelfreak](https://github.com/bastelfreak))

## [v2.3.0](https://github.com/voxpupuli/puppet-gluster/tree/v2.3.0) (2017-01-13)

[Full Changelog](https://github.com/voxpupuli/puppet-gluster/compare/v2.2.3...v2.3.0)

**Merged pull requests:**

- Set min version\_requirement for Puppet + deps [\#97](https://github.com/voxpupuli/puppet-gluster/pull/97) ([juniorsysadmin](https://github.com/juniorsysadmin))

## [v2.2.3](https://github.com/voxpupuli/puppet-gluster/tree/v2.2.3) (2016-11-25)

[Full Changelog](https://github.com/voxpupuli/puppet-gluster/compare/v2.2.2...v2.2.3)

**Closed issues:**

- Module doesn't work with Puppet 4 due to undef variable passing [\#82](https://github.com/voxpupuli/puppet-gluster/issues/82)
- Heketi Support [\#81](https://github.com/voxpupuli/puppet-gluster/issues/81)

**Merged pull requests:**

- Release 2.2.3 [\#90](https://github.com/voxpupuli/puppet-gluster/pull/90) ([alexjfisher](https://github.com/alexjfisher))
- Fixes and tests for strict variables [\#87](https://github.com/voxpupuli/puppet-gluster/pull/87) ([alexjfisher](https://github.com/alexjfisher))

## [v2.2.2](https://github.com/voxpupuli/puppet-gluster/tree/v2.2.2) (2016-10-24)

[Full Changelog](https://github.com/voxpupuli/puppet-gluster/compare/v2.2.1...v2.2.2)

**Closed issues:**

- Update Test Cases for RedHat/YUM [\#76](https://github.com/voxpupuli/puppet-gluster/issues/76)
- Can't add yum repositories [\#68](https://github.com/voxpupuli/puppet-gluster/issues/68)

**Merged pull requests:**

- Updating Test Cases for YUM and RPM installation [\#78](https://github.com/voxpupuli/puppet-gluster/pull/78) ([tux-o-matic](https://github.com/tux-o-matic))
- release 2.2.2 [\#77](https://github.com/voxpupuli/puppet-gluster/pull/77) ([bastelfreak](https://github.com/bastelfreak))
- Fixed CentOS storage SIG GPG key \(issue \#63 \#68\) and server package name [\#74](https://github.com/voxpupuli/puppet-gluster/pull/74) ([mkmet](https://github.com/mkmet))
- Fix a misspelling of "therefore" [\#73](https://github.com/voxpupuli/puppet-gluster/pull/73) ([pioto](https://github.com/pioto))

## [v2.2.1](https://github.com/voxpupuli/puppet-gluster/tree/v2.2.1) (2016-10-12)

[Full Changelog](https://github.com/voxpupuli/puppet-gluster/compare/v2.2.0...v2.2.1)

**Merged pull requests:**

- release 2.2.1 [\#72](https://github.com/voxpupuli/puppet-gluster/pull/72) ([bastelfreak](https://github.com/bastelfreak))
- Switched YUM repo to use the new CentOS Storage group repository [\#69](https://github.com/voxpupuli/puppet-gluster/pull/69) ([tux-o-matic](https://github.com/tux-o-matic))

## [v2.2.0](https://github.com/voxpupuli/puppet-gluster/tree/v2.2.0) (2016-08-17)

[Full Changelog](https://github.com/voxpupuli/puppet-gluster/compare/v2.1.0...v2.2.0)

**Merged pull requests:**

- release 2.2.0 [\#67](https://github.com/voxpupuli/puppet-gluster/pull/67) ([bastelfreak](https://github.com/bastelfreak))
- Archlinux Support [\#55](https://github.com/voxpupuli/puppet-gluster/pull/55) ([bastelfreak](https://github.com/bastelfreak))

## [v2.1.0](https://github.com/voxpupuli/puppet-gluster/tree/v2.1.0) (2016-08-10)

[Full Changelog](https://github.com/voxpupuli/puppet-gluster/compare/v2.0.1...v2.1.0)

**Closed issues:**

- Release to puppet forge. [\#32](https://github.com/voxpupuli/puppet-gluster/issues/32)

**Merged pull requests:**

- Release 2.1.0 [\#62](https://github.com/voxpupuli/puppet-gluster/pull/62) ([DarkGigaByte](https://github.com/DarkGigaByte))
- Debian support [\#59](https://github.com/voxpupuli/puppet-gluster/pull/59) ([NITEMAN](https://github.com/NITEMAN))

## [v2.0.1](https://github.com/voxpupuli/puppet-gluster/tree/v2.0.1) (2016-05-11)

[Full Changelog](https://github.com/voxpupuli/puppet-gluster/compare/v2.0.0...v2.0.1)

**Implemented enhancements:**

- Use delete\_undef\_values\(\) for mount options [\#39](https://github.com/voxpupuli/puppet-gluster/pull/39) ([skpy](https://github.com/skpy))

**Merged pull requests:**

- Release 2.0.1 [\#52](https://github.com/voxpupuli/puppet-gluster/pull/52) ([bastelfreak](https://github.com/bastelfreak))

## [v2.0.0](https://github.com/voxpupuli/puppet-gluster/tree/v2.0.0) (2016-05-11)

[Full Changelog](https://github.com/voxpupuli/puppet-gluster/compare/9f78c28ca2058eb3602f31609bcb6e94fcfedd01...v2.0.0)

**Implemented enhancements:**

- Enabling first volume creation on Puppet \> 4 [\#24](https://github.com/voxpupuli/puppet-gluster/pull/24) ([tux-o-matic](https://github.com/tux-o-matic))

**Closed issues:**

-  Volume creation has race condition with fact gluster\_volume\_list [\#23](https://github.com/voxpupuli/puppet-gluster/issues/23)
- missing tag on forge.puppetlabs.com [\#22](https://github.com/voxpupuli/puppet-gluster/issues/22)
- Cannot reassign variable r at volume.pp:264 [\#18](https://github.com/voxpupuli/puppet-gluster/issues/18)
- Mounts can be defined but mount point will not be created [\#16](https://github.com/voxpupuli/puppet-gluster/issues/16)
- refreshes to gluster::mount fail to remount the volume [\#10](https://github.com/voxpupuli/puppet-gluster/issues/10)
- Support yum priorities [\#4](https://github.com/voxpupuli/puppet-gluster/issues/4)
- ::gluster::volume doesn't create volumes from hosts included in the volume [\#3](https://github.com/voxpupuli/puppet-gluster/issues/3)
- A stopped volume aborts a Puppet run [\#1](https://github.com/voxpupuli/puppet-gluster/issues/1)

**Merged pull requests:**

- Release 2.0.0 [\#51](https://github.com/voxpupuli/puppet-gluster/pull/51) ([bastelfreak](https://github.com/bastelfreak))
- Fix error message: Undefined variable ::operatingsystemmajrelease [\#44](https://github.com/voxpupuli/puppet-gluster/pull/44) ([dhoppe](https://github.com/dhoppe))
- GH-22: Add tags to metadata.json [\#41](https://github.com/voxpupuli/puppet-gluster/pull/41) ([jyaworski](https://github.com/jyaworski))
- Use force Parameter when adding brick to existing volume [\#38](https://github.com/voxpupuli/puppet-gluster/pull/38) ([rauchrob](https://github.com/rauchrob))
- Update hyperlink in README.md [\#37](https://github.com/voxpupuli/puppet-gluster/pull/37) ([rauchrob](https://github.com/rauchrob))
- Fix flags parameter of regsubst function call [\#36](https://github.com/voxpupuli/puppet-gluster/pull/36) ([rauchrob](https://github.com/rauchrob))
- Update yum repo url [\#35](https://github.com/voxpupuli/puppet-gluster/pull/35) ([rauchrob](https://github.com/rauchrob))
- Corrected mount options needing to be prefixed by the option name as … [\#30](https://github.com/voxpupuli/puppet-gluster/pull/30) ([valsr](https://github.com/valsr))
- update README to declare move to Puppet Community [\#27](https://github.com/voxpupuli/puppet-gluster/pull/27) ([skpy](https://github.com/skpy))
- Fix reuse of variable name in volume.pp [\#21](https://github.com/voxpupuli/puppet-gluster/pull/21) ([zstyblik](https://github.com/zstyblik))
- Set repo priority to 'undef' [\#17](https://github.com/voxpupuli/puppet-gluster/pull/17) ([chuman](https://github.com/chuman))
- \_netdev is not required for glusterfs. [\#13](https://github.com/voxpupuli/puppet-gluster/pull/13) ([robertdebock](https://github.com/robertdebock))
- add tests [\#12](https://github.com/voxpupuli/puppet-gluster/pull/12) ([skpy](https://github.com/skpy))
- Pass remounts =\> false to mount resources [\#11](https://github.com/voxpupuli/puppet-gluster/pull/11) ([skpy](https://github.com/skpy))
- Handle failures from `gluster volume status foo` [\#9](https://github.com/voxpupuli/puppet-gluster/pull/9) ([skpy](https://github.com/skpy))
- Add support \(and documentation\) for yum priorities [\#5](https://github.com/voxpupuli/puppet-gluster/pull/5) ([skpy](https://github.com/skpy))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
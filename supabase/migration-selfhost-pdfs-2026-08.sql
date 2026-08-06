-- ============================================================
-- Parklea SFC - repoint legacy PDF links to self-hosted copies
--
-- www.parkleasfc.com.au serves these over http only, and its :443
-- listener fails the TLS handshake outright. Browsers that upgrade
-- http navigations (Chrome does by default now) land on
-- ERR_SSL_VERSION_OR_CIPHER_MISMATCH and the link is simply dead.
--
-- All 36 PDFs are now committed at parklea-site/public/docs/ and
-- served from this site over https as /docs/<file>.pdf.
--
-- Safe to re-run: each statement matches one exact old URL.
-- Run in Supabase Dashboard -> SQL Editor.
-- ============================================================

begin;

-- ---------- policies.url ----------
update public.policies set url = '/docs/2026_committee_nomination_form_final.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/2026_committee_nomination_form_final.pdf';
update public.policies set url = '/docs/appendix-b-u8-bdsfa-regulations.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/appendix-b-u8-bdsfa-regulations.pdf';
update public.policies set url = '/docs/appendix-c-u9-bdsfa-regulations.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/appendix-c-u9-bdsfa-regulations.pdf';
update public.policies set url = '/docs/appendix-d-u10-bdsfa-regulations.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/appendix-d-u10-bdsfa-regulations.pdf';
update public.policies set url = '/docs/appendix-f-u9-girls-bdsfa-regulations.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/appendix-f-u9-girls-bdsfa-regulations.pdf';
update public.policies set url = '/docs/code_of_behaviour_coach.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_coach.pdf';
update public.policies set url = '/docs/code_of_behaviour_manager.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_manager.pdf';
update public.policies set url = '/docs/code_of_behaviour_official.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_official.pdf';
update public.policies set url = '/docs/code_of_behaviour_parent.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_parent.pdf';
update public.policies set url = '/docs/code_of_behaviour_player.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_player.pdf';
update public.policies set url = '/docs/document_-_ground_official_guidelines_copy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/document_-_ground_official_guidelines_copy.pdf';
update public.policies set url = '/docs/document_-_match_day_supervisor_guidelines.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/document_-_match_day_supervisor_guidelines.pdf';
update public.policies set url = '/docs/ezidebit_form_-_instructions.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/ezidebit_form_-_instructions.pdf';
update public.policies set url = '/docs/fnsw_hot_weather_policy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/fnsw_hot_weather_policy.pdf';
update public.policies set url = '/docs/fnsw_lightning_policy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/fnsw_lightning_policy.pdf';
update public.policies set url = '/docs/goalpost-safety-policy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/goalpost-safety-policy.pdf';
update public.policies set url = '/docs/policy-alcohol.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-alcohol.pdf';
update public.policies set url = '/docs/policy-concussion.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-concussion.pdf';
update public.policies set url = '/docs/policy-injury.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-injury.pdf';
update public.policies set url = '/docs/policy-privacy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-privacy.pdf';
update public.policies set url = '/docs/policy-referee-payment.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-referee-payment.pdf';
update public.policies set url = '/docs/policy-social-media.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-social-media.pdf';
update public.policies set url = '/docs/policy-video-images.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-video-images.pdf';
update public.policies set url = '/docs/policy_-_game_leader_copy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy_-_game_leader_copy.pdf';
update public.policies set url = '/docs/policy_-_miniroos.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy_-_miniroos.pdf';
update public.policies set url = '/docs/pregnancy-policy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/pregnancy-policy.pdf';
update public.policies set url = '/docs/psfc_by_laws___regulations_120618.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/psfc_by_laws___regulations_120618.pdf';
update public.policies set url = '/docs/psfc_constitution.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/psfc_constitution.pdf';
update public.policies set url = '/docs/refund_policy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/refund_policy.pdf';
update public.policies set url = '/docs/smoking-policy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/smoking-policy.pdf';
update public.policies set url = '/docs/social_media_policy_fnsw.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/social_media_policy_fnsw.pdf';
update public.policies set url = '/docs/training_allocation_2026_v4.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/training_allocation_2026_v4.pdf';
update public.policies set url = '/docs/u5_-_7_bdsfa_regulations.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/u5_-_7_bdsfa_regulations.pdf';
update public.policies set url = '/docs/under_5s_to_7s_faqs_2026.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/under_5s_to_7s_faqs_2026.pdf';
update public.policies set url = '/docs/working-with-children-check-policy-20190504-1.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/working-with-children-check-policy-20190504-1.pdf';
update public.policies set url = '/docs/zero_tolerance_policy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/zero_tolerance_policy.pdf';

-- ---------- quick_links.url ----------
update public.quick_links set url = '/docs/2026_committee_nomination_form_final.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/2026_committee_nomination_form_final.pdf';
update public.quick_links set url = '/docs/appendix-b-u8-bdsfa-regulations.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/appendix-b-u8-bdsfa-regulations.pdf';
update public.quick_links set url = '/docs/appendix-c-u9-bdsfa-regulations.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/appendix-c-u9-bdsfa-regulations.pdf';
update public.quick_links set url = '/docs/appendix-d-u10-bdsfa-regulations.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/appendix-d-u10-bdsfa-regulations.pdf';
update public.quick_links set url = '/docs/appendix-f-u9-girls-bdsfa-regulations.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/appendix-f-u9-girls-bdsfa-regulations.pdf';
update public.quick_links set url = '/docs/code_of_behaviour_coach.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_coach.pdf';
update public.quick_links set url = '/docs/code_of_behaviour_manager.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_manager.pdf';
update public.quick_links set url = '/docs/code_of_behaviour_official.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_official.pdf';
update public.quick_links set url = '/docs/code_of_behaviour_parent.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_parent.pdf';
update public.quick_links set url = '/docs/code_of_behaviour_player.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_player.pdf';
update public.quick_links set url = '/docs/document_-_ground_official_guidelines_copy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/document_-_ground_official_guidelines_copy.pdf';
update public.quick_links set url = '/docs/document_-_match_day_supervisor_guidelines.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/document_-_match_day_supervisor_guidelines.pdf';
update public.quick_links set url = '/docs/ezidebit_form_-_instructions.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/ezidebit_form_-_instructions.pdf';
update public.quick_links set url = '/docs/fnsw_hot_weather_policy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/fnsw_hot_weather_policy.pdf';
update public.quick_links set url = '/docs/fnsw_lightning_policy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/fnsw_lightning_policy.pdf';
update public.quick_links set url = '/docs/goalpost-safety-policy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/goalpost-safety-policy.pdf';
update public.quick_links set url = '/docs/policy-alcohol.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-alcohol.pdf';
update public.quick_links set url = '/docs/policy-concussion.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-concussion.pdf';
update public.quick_links set url = '/docs/policy-injury.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-injury.pdf';
update public.quick_links set url = '/docs/policy-privacy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-privacy.pdf';
update public.quick_links set url = '/docs/policy-referee-payment.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-referee-payment.pdf';
update public.quick_links set url = '/docs/policy-social-media.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-social-media.pdf';
update public.quick_links set url = '/docs/policy-video-images.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-video-images.pdf';
update public.quick_links set url = '/docs/policy_-_game_leader_copy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy_-_game_leader_copy.pdf';
update public.quick_links set url = '/docs/policy_-_miniroos.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy_-_miniroos.pdf';
update public.quick_links set url = '/docs/pregnancy-policy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/pregnancy-policy.pdf';
update public.quick_links set url = '/docs/psfc_by_laws___regulations_120618.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/psfc_by_laws___regulations_120618.pdf';
update public.quick_links set url = '/docs/psfc_constitution.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/psfc_constitution.pdf';
update public.quick_links set url = '/docs/refund_policy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/refund_policy.pdf';
update public.quick_links set url = '/docs/smoking-policy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/smoking-policy.pdf';
update public.quick_links set url = '/docs/social_media_policy_fnsw.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/social_media_policy_fnsw.pdf';
update public.quick_links set url = '/docs/training_allocation_2026_v4.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/training_allocation_2026_v4.pdf';
update public.quick_links set url = '/docs/u5_-_7_bdsfa_regulations.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/u5_-_7_bdsfa_regulations.pdf';
update public.quick_links set url = '/docs/under_5s_to_7s_faqs_2026.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/under_5s_to_7s_faqs_2026.pdf';
update public.quick_links set url = '/docs/working-with-children-check-policy-20190504-1.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/working-with-children-check-policy-20190504-1.pdf';
update public.quick_links set url = '/docs/zero_tolerance_policy.pdf' where url = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/zero_tolerance_policy.pdf';

-- ---------- page_content.value ----------
update public.page_content set value = '/docs/2026_committee_nomination_form_final.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/2026_committee_nomination_form_final.pdf';
update public.page_content set value = '/docs/appendix-b-u8-bdsfa-regulations.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/appendix-b-u8-bdsfa-regulations.pdf';
update public.page_content set value = '/docs/appendix-c-u9-bdsfa-regulations.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/appendix-c-u9-bdsfa-regulations.pdf';
update public.page_content set value = '/docs/appendix-d-u10-bdsfa-regulations.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/appendix-d-u10-bdsfa-regulations.pdf';
update public.page_content set value = '/docs/appendix-f-u9-girls-bdsfa-regulations.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/appendix-f-u9-girls-bdsfa-regulations.pdf';
update public.page_content set value = '/docs/code_of_behaviour_coach.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_coach.pdf';
update public.page_content set value = '/docs/code_of_behaviour_manager.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_manager.pdf';
update public.page_content set value = '/docs/code_of_behaviour_official.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_official.pdf';
update public.page_content set value = '/docs/code_of_behaviour_parent.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_parent.pdf';
update public.page_content set value = '/docs/code_of_behaviour_player.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_player.pdf';
update public.page_content set value = '/docs/document_-_ground_official_guidelines_copy.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/document_-_ground_official_guidelines_copy.pdf';
update public.page_content set value = '/docs/document_-_match_day_supervisor_guidelines.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/document_-_match_day_supervisor_guidelines.pdf';
update public.page_content set value = '/docs/ezidebit_form_-_instructions.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/ezidebit_form_-_instructions.pdf';
update public.page_content set value = '/docs/fnsw_hot_weather_policy.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/fnsw_hot_weather_policy.pdf';
update public.page_content set value = '/docs/fnsw_lightning_policy.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/fnsw_lightning_policy.pdf';
update public.page_content set value = '/docs/goalpost-safety-policy.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/goalpost-safety-policy.pdf';
update public.page_content set value = '/docs/policy-alcohol.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-alcohol.pdf';
update public.page_content set value = '/docs/policy-concussion.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-concussion.pdf';
update public.page_content set value = '/docs/policy-injury.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-injury.pdf';
update public.page_content set value = '/docs/policy-privacy.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-privacy.pdf';
update public.page_content set value = '/docs/policy-referee-payment.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-referee-payment.pdf';
update public.page_content set value = '/docs/policy-social-media.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-social-media.pdf';
update public.page_content set value = '/docs/policy-video-images.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-video-images.pdf';
update public.page_content set value = '/docs/policy_-_game_leader_copy.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy_-_game_leader_copy.pdf';
update public.page_content set value = '/docs/policy_-_miniroos.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy_-_miniroos.pdf';
update public.page_content set value = '/docs/pregnancy-policy.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/pregnancy-policy.pdf';
update public.page_content set value = '/docs/psfc_by_laws___regulations_120618.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/psfc_by_laws___regulations_120618.pdf';
update public.page_content set value = '/docs/psfc_constitution.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/psfc_constitution.pdf';
update public.page_content set value = '/docs/refund_policy.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/refund_policy.pdf';
update public.page_content set value = '/docs/smoking-policy.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/smoking-policy.pdf';
update public.page_content set value = '/docs/social_media_policy_fnsw.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/social_media_policy_fnsw.pdf';
update public.page_content set value = '/docs/training_allocation_2026_v4.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/training_allocation_2026_v4.pdf';
update public.page_content set value = '/docs/u5_-_7_bdsfa_regulations.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/u5_-_7_bdsfa_regulations.pdf';
update public.page_content set value = '/docs/under_5s_to_7s_faqs_2026.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/under_5s_to_7s_faqs_2026.pdf';
update public.page_content set value = '/docs/working-with-children-check-policy-20190504-1.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/working-with-children-check-policy-20190504-1.pdf';
update public.page_content set value = '/docs/zero_tolerance_policy.pdf' where value = 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/zero_tolerance_policy.pdf';

-- Verify: all three should report 0 before you commit.
select 'policies' as tbl, count(*) as legacy_left from public.policies where url like '%www.parkleasfc.com.au%';
select 'quick_links' as tbl, count(*) as legacy_left from public.quick_links where url like '%www.parkleasfc.com.au%';
select 'page_content' as tbl, count(*) as legacy_left from public.page_content where value like '%www.parkleasfc.com.au%';

commit;

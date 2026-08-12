-- ═══════════════════════════════════════════════════════════════════════════
--  credit_photo — champ photographe dans le dépôt artiste (Sur nos pages)
--  2026-08-12 · directive Cédric 2026-08-10 via Apollon → Héphaïstos
-- ═══════════════════════════════════════════════════════════════════════════

ALTER TABLE public.artistes_pages
  ADD COLUMN IF NOT EXISTS credit_photo text;

CREATE OR REPLACE FUNCTION public.maj_dossier_pages(p_token text, p_payload jsonb)
 RETURNS artistes_pages
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare v_row public.artistes_pages;
begin
  update public.artistes_pages set
    bio               = case when p_payload ? 'bio'               then p_payload->>'bio' else bio end,
    titre_livre       = case when p_payload ? 'titre_livre'       then p_payload->>'titre_livre' else titre_livre end,
    editeur           = case when p_payload ? 'editeur'           then p_payload->>'editeur' else editeur end,
    annee_publication = case when p_payload ? 'annee_publication' then nullif(p_payload->>'annee_publication','')::int else annee_publication end,
    isbn              = case when p_payload ? 'isbn'              then p_payload->>'isbn' else isbn end,
    extrait           = case when p_payload ? 'extrait'           then p_payload->>'extrait' else extrait end,
    extrait_pdf_path  = case when p_payload ? 'extrait_pdf_path'  then p_payload->>'extrait_pdf_path' else extrait_pdf_path end,
    duree_souhaitee   = case when p_payload ? 'duree_souhaitee'   then p_payload->>'duree_souhaitee' else duree_souhaitee end,
    cellulaire        = case when p_payload ? 'cellulaire'        then p_payload->>'cellulaire' else cellulaire end,
    instagram         = case when p_payload ? 'instagram'         then p_payload->>'instagram' else instagram end,
    facebook          = case when p_payload ? 'facebook'          then p_payload->>'facebook' else facebook end,
    site_web          = case when p_payload ? 'site_web'          then p_payload->>'site_web' else site_web end,
    besoin_micro      = case when p_payload ? 'besoin_micro'      then (p_payload->>'besoin_micro')::boolean else besoin_micro end,
    besoin_projection = case when p_payload ? 'besoin_projection' then (p_payload->>'besoin_projection')::boolean else besoin_projection end,
    besoin_table      = case when p_payload ? 'besoin_table'      then (p_payload->>'besoin_table')::boolean else besoin_table end,
    vente_livres      = case when p_payload ? 'vente_livres'      then (p_payload->>'vente_livres')::boolean else vente_livres end,
    photo_artiste_path = case when p_payload ? 'photo_artiste_path' then p_payload->>'photo_artiste_path' else photo_artiste_path end,
    signature_acceptee = case when p_payload ? 'signature_acceptee' then (p_payload->>'signature_acceptee')::boolean else signature_acceptee end,
    signature_nom     = case when p_payload ? 'signature_nom'     then p_payload->>'signature_nom' else signature_nom end,
    signature_le      = case when p_payload ? 'signature_le'      then nullif(p_payload->>'signature_le','')::timestamptz else signature_le end,
    credit_photo      = case when p_payload ? 'credit_photo'      then p_payload->>'credit_photo' else credit_photo end,
    statut            = case when p_payload->>'statut' in ('candidature_complete','depot_complet') then p_payload->>'statut' else statut end,
    maj_le            = now()
  where token_depot = p_token
  returning * into v_row;
  if not found then raise exception 'token inconnu'; end if;
  return v_row;
end;
$function$;

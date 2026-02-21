-- 샘플 문서는 앱에서 "문서 만들기"로 생성 가능.
-- 로컬 테스트용: 첫 번째 사용자에게 샘플 문서 1개 부여 (선택)
DO $$
DECLARE
  uid UUID;
  doc_id UUID;
  node_id UUID;
BEGIN
  SELECT id INTO uid FROM auth.users LIMIT 1;
  IF uid IS NOT NULL THEN
    INSERT INTO public.documents (user_id, title)
    VALUES (uid, '샘플 마인드맵')
    RETURNING id INTO doc_id;
    INSERT INTO public.nodes (document_id, order_index, title)
    VALUES (doc_id, 0, '중심 주제')
    RETURNING id INTO node_id;
    UPDATE public.documents SET root_node_id = node_id, updated_at = now() WHERE id = doc_id;
  END IF;
END $$;

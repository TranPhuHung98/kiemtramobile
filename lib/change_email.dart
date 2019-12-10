class ChangeEmail{
  String changeEmail(String email){
        String em = email ;
     for(int i =0 ; i < em.length; i ++ )
      if(em[i] == '.')
        em = em.replaceRange(i,i+1, '_');
    return em;
  }
}
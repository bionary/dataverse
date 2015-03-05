/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.harvard.iq.dataverse.api.imports;

import edu.harvard.iq.dataverse.util.ImportLogger;
import javax.ejb.EJB;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.PersistenceContext;

/**
 *
 * @author ellenk
 */
@Stateless
public class CustomFieldServiceBean {

    @EJB
    ImportLogger importLogger;

     @PersistenceContext(unitName = "VDCNet-ejbPU")
    private EntityManager em;
     
    public CustomFieldMap findByTemplateField(String template, String field) {
        try {
            CustomFieldMap map = (CustomFieldMap) em.createNamedQuery("CustomFieldMap.findByTemplateField").setParameter("template", template).setParameter("field", field).getSingleResult();
            return map;
        } catch (NoResultException ex) {
            return null;
        }

    }

}